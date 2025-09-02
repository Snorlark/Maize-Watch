import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import { HTTP_STATUS, RESPONSE_MESSAGES } from '../utils/constants';
import { logger } from '../utils/logger';

// Custom error class
export class AppError extends Error {
  public statusCode: number;
  public status: string;
  public isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}

// Handle MongoDB cast errors
const handleCastErrorDB = (err: mongoose.Error.CastError): AppError => {
  const message = `Invalid ${err.path}: ${err.value}`;
  return new AppError(message, HTTP_STATUS.BAD_REQUEST);
};

// Handle MongoDB duplicate field errors
const handleDuplicateFieldsDB = (err: any): AppError => {
  const value = err.errmsg?.match(/(["'])(\\?.)*?\1/)?.[0];
  const message = `Duplicate field value: ${value}. Please use another value!`;
  return new AppError(message, HTTP_STATUS.CONFLICT);
};

// Handle MongoDB validation errors
const handleValidationErrorDB = (err: mongoose.Error.ValidationError): AppError => {
  const errors = Object.values(err.errors).map(el => el.message);
  const message = `Invalid input data. ${errors.join('. ')}`;
  return new AppError(message, HTTP_STATUS.UNPROCESSABLE_ENTITY);
};

// Handle JWT errors
const handleJWTError = (): AppError =>
  new AppError('Invalid token. Please log in again!', HTTP_STATUS.UNAUTHORIZED);

const handleJWTExpiredError = (): AppError =>
  new AppError('Your token has expired! Please log in again.', HTTP_STATUS.UNAUTHORIZED);

// Send error response for development
const sendErrorDev = (err: AppError, req: Request, res: Response): void => {
  // Log error
  logger.error('Error:', {
    error: err,
    request: {
      method: req.method,
      url: req.originalUrl,
      headers: req.headers,
      body: req.body,
      params: req.params,
      query: req.query,
    },
  });

  res.status(err.statusCode).json({
    success: false,
    error: err,
    message: err.message,
    stack: err.stack,
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString(),
  });
};

// Send error response for production
const sendErrorProd = (err: AppError, req: Request, res: Response): void => {
  // Operational, trusted error: send message to client
  if (err.isOperational) {
    logger.error('Operational Error:', {
      message: err.message,
      statusCode: err.statusCode,
      path: req.originalUrl,
      method: req.method,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
    });

    res.status(err.statusCode).json({
      success: false,
      message: err.message,
      path: req.originalUrl,
      timestamp: new Date().toISOString(),
    });
  } else {
    // Programming or other unknown error: don't leak error details
    logger.error('Programming Error:', {
      error: err,
      path: req.originalUrl,
      method: req.method,
      userAgent: req.get('User-Agent'),
      ip: req.ip,
    });

    res.status(HTTP_STATUS.INTERNAL_SERVER_ERROR).json({
      success: false,
      message: RESPONSE_MESSAGES.ERROR.INTERNAL_ERROR,
      path: req.originalUrl,
      timestamp: new Date().toISOString(),
    });
  }
};

// Global error handling middleware
const globalErrorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  err.statusCode = err.statusCode || HTTP_STATUS.INTERNAL_SERVER_ERROR;
  err.status = err.status || 'error';

  if (process.env.NODE_ENV === 'development') {
    sendErrorDev(err, req, res);
  } else {
    let error = { ...err };
    error.message = err.message;

    // Handle specific error types
    if (error.name === 'CastError') error = handleCastErrorDB(error);
    if (error.code === 11000) error = handleDuplicateFieldsDB(error);
    if (error.name === 'ValidationError') error = handleValidationErrorDB(error);
    if (error.name === 'JsonWebTokenError') error = handleJWTError();
    if (error.name === 'TokenExpiredError') error = handleJWTExpiredError();

    sendErrorProd(error, req, res);
  }
};

// Handle unhandled promise rejections
export const handleUnhandledRejection = (): void => {
  process.on('unhandledRejection', (err: Error) => {
    logger.error('UNHANDLED REJECTION! 💥 Shutting down...', err);
    process.exit(1);
  });
};

// Handle uncaught exceptions
export const handleUncaughtException = (): void => {
  process.on('uncaughtException', (err: Error) => {
    logger.error('UNCAUGHT EXCEPTION! 💥 Shutting down...', err);
    process.exit(1);
  });
};

// 404 handler for undefined routes
export const notFound = (req: Request, res: Response, next: NextFunction): void => {
  const err = new AppError(`Can't find ${req.originalUrl} on this server!`, HTTP_STATUS.NOT_FOUND);
  next(err);
};

// Async error wrapper
export const catchAsync = (fn: Function) => {
  return (req: Request, res: Response, next: NextFunction) => {
    fn(req, res, next).catch(next);
  };
};

export { globalErrorHandler as default };
