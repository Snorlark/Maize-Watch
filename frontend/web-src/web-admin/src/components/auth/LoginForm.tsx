
// LoginForm.tsx
import React, { useState, useEffect } from 'react';
import { Eye, EyeOff, Mail, Shield, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

type LoginStep = 'password' | 'otp' | 'forgot-email' | 'forgot-otp' | 'forgot-reset';

const LoginForm: React.FC = () => {
  const navigate = useNavigate();
  const ADMIN_PATH = import.meta.env.VITE_ADMIN_PATH || 'admin-portal-xyz123';
  const [showPassword, setShowPassword] = useState(false);
  const { login, verifyOTP, resendLoginOTP, sendForgotPasswordOTP, verifyForgotPasswordOTP, resetPassword } = useAuth();

  // Form states
  const [currentStep, setCurrentStep] = useState<LoginStep>('password');
  const [usernameOrEmail, setUsernameOrEmail] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  
  // Forgot password specific states
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotOtp, setForgotOtp] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  
  // OTP specific states
  const [countdown, setCountdown] = useState<number>(300); // 5 minutes
  const [resendCountdown, setResendCountdown] = useState<number>(0); // Resend cooldown in seconds
  const [forgotResendCountdown, setForgotResendCountdown] = useState<number>(0); // Forgot password resend cooldown

  // Countdown timer for OTP expiry
  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (currentStep === 'otp' && countdown > 0) {
      timer = setTimeout(() => setCountdown(countdown - 1), 1000);
    } else if (currentStep === 'otp' && countdown === 0) {
      setCurrentStep('password');
      setError('Verification code expired. Please try logging in again.');
    }
    return () => clearTimeout(timer);
  }, [countdown, currentStep]);

  // Countdown timer for resend OTP cooldown
  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (currentStep === 'otp' && resendCountdown > 0) {
      timer = setTimeout(() => setResendCountdown(resendCountdown - 1), 1000);
    }
    return () => clearTimeout(timer);
  }, [resendCountdown, currentStep]);

  // Countdown timer for forgot password resend OTP cooldown
  useEffect(() => {
    let timer: NodeJS.Timeout;
    if (currentStep === 'forgot-otp' && forgotResendCountdown > 0) {
      timer = setTimeout(() => setForgotResendCountdown(forgotResendCountdown - 1), 1000);
    }
    return () => clearTimeout(timer);
  }, [forgotResendCountdown, currentStep]);

  // Handle password login (Step 1)
  const handlePasswordLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    if (!usernameOrEmail || !password) {
      setError('Username/Email and password are required');
      setLoading(false);
      return;
    }

    try {
      const result = await login(usernameOrEmail, password);
      
      if (result.success) {
        if (result.requiresOTP) {
          // Admin user - proceed to OTP step
          const emailFromResponse = (result as any).data?.email || result.email || '';
          setEmail(emailFromResponse);
          setCurrentStep('otp');
          setCountdown(300); // 5 minutes
          setResendCountdown(60); // 1 minute cooldown for resend
          setSuccess(result.message || 'Verification code sent to your email');
        } else {
          navigate(`/${ADMIN_PATH}/dashboard`);
        }
      } else {
        setError(result.message || 'Invalid username/email or password');
      }
    } catch (err: any) {
      console.error('Login failed:', err);
      setError('Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Handle OTP verification (Step 2)
  const handleVerifyOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    if (!otp || otp.length !== 6) {
      setError('Please enter a valid 6-digit verification code');
      setLoading(false);
      return;
    }

    try {
      const success = await verifyOTP(email, otp);
      
      if (success) {
        navigate(`/${ADMIN_PATH}/dashboard`);
      } else {
        setError('Invalid verification code. Please try again.');
      }
    } catch (err: any) {
      console.error('OTP verification failed:', err);
      setError('Verification failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Reset to password step
  const backToPasswordStep = () => {
    setCurrentStep('password');
    setOtp('');
    setCountdown(0);
    setResendCountdown(0);
    setError('');
    setSuccess('');
  };

  // Handle resend OTP
  const handleResendOTP = async () => {
    // Prevent resend if cooldown is active
    if (resendCountdown > 0) {
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      const result = await resendLoginOTP(email);
      
      if (result.success) {
        setCountdown(300); // Reset countdown to 5 minutes
        setResendCountdown(60); // Reset resend cooldown to 1 minute
        setSuccess('Verification code resent to your email');
      } else {
        setError(result.message || 'Failed to resend verification code');
      }
    } catch (err: any) {
      console.error('Resend OTP failed:', err);
      setError('Failed to resend verification code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Handle forgot password flow
  const handleForgotPassword = () => {
    setCurrentStep('forgot-email');
    setError('');
    setSuccess('');
    setForgotEmail('');
  };

  // Send forgot password OTP
  const handleSendForgotPasswordOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    if (!forgotEmail) {
      setError('Email is required');
      setLoading(false);
      return;
    }

    try {
      const result = await sendForgotPasswordOTP(forgotEmail);
      
      if (result.success) {
        setCurrentStep('forgot-otp');
        setSuccess('Verification code sent to your email');
        setCountdown(300); // 5 minutes
        setForgotResendCountdown(60); // 1 minute cooldown for resend
      } else {
        setError(result.message || 'Failed to send verification code');
      }
    } catch (err: any) {
      console.error('Send forgot password OTP failed:', err);
      setError('Failed to send verification code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Verify forgot password OTP
  const handleVerifyForgotPasswordOTP = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    if (!forgotOtp || forgotOtp.length !== 6) {
      setError('Please enter a valid 6-digit verification code');
      setLoading(false);
      return;
    }

    try {
      const result = await verifyForgotPasswordOTP(forgotEmail, forgotOtp);
      
      if (result.success) {
        setCurrentStep('forgot-reset');
        setSuccess('Verification successful. Please set your new password.');
      } else {
        setError(result.message || 'Invalid verification code');
      }
    } catch (err: any) {
      console.error('Verify forgot password OTP failed:', err);
      setError('Verification failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Reset password
  const handleResetPassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    setSuccess('');

    if (!newPassword || newPassword.length < 8) {
      setError('Password must be at least 8 characters long');
      setLoading(false);
      return;
    }

    if (newPassword !== confirmPassword) {
      setError('Passwords do not match');
      setLoading(false);
      return;
    }

    try {
      const result = await resetPassword(forgotEmail, forgotOtp, newPassword);
      
      if (result.success) {
        setSuccess('Password reset successful! You can now login with your new password.');
        // Reset form and go back to login
        setTimeout(() => {
          setCurrentStep('password');
          setForgotEmail('');
          setForgotOtp('');
          setNewPassword('');
          setConfirmPassword('');
          setError('');
          setSuccess('');
        }, 2000);
      } else {
        setError(result.message || 'Failed to reset password');
      }
    } catch (err: any) {
      console.error('Reset password failed:', err);
      setError('Failed to reset password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  // Back to login from forgot password flow
  const backToLogin = () => {
    setCurrentStep('password');
    setForgotEmail('');
    setForgotOtp('');
    setNewPassword('');
    setConfirmPassword('');
    setError('');
    setSuccess('');
    setCountdown(0);
    setForgotResendCountdown(0);
  };

  // Handle resend forgot password OTP
  const handleResendForgotPasswordOTP = async () => {
    // Prevent resend if cooldown is active
    if (forgotResendCountdown > 0) {
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      const result = await sendForgotPasswordOTP(forgotEmail);
      
      if (result.success) {
        setCountdown(300); // Reset countdown to 5 minutes
        setForgotResendCountdown(60); // Reset resend cooldown to 1 minute
        setSuccess('Verification code resent to your email');
      } else {
        setError(result.message || 'Failed to resend verification code');
      }
    } catch (err: any) {
      console.error('Resend forgot password OTP failed:', err);
      setError('Failed to resend verification code. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="bg-white">
      <section className="bg-[url(/images/background.png)] relative min-h-screen bg-cover bg-center flex flex-col items-center justify-center px-4 md:px-10">
        <div className="mt-10 md:mt-10 flex flex-col items-center justify-center z-10 space-y-6  pt-0 pb-20">
          <div>
            <img
              src="/images/loginsignuplogo.png"
              alt="Maize Watch Text"
              className="w-60 md:w-80 lg:w-160"
            />
          </div>
          <div className="login-form w-full max-w-xl bg-white/10 backdrop-blur-md rounded-2xl p-6 sm:p-8 text-white shadow-lg">
            <div className="text-center mb-6">
              <h2 className="text-2xl md:text-3xl font-bold mb-4">
                {currentStep === 'password' ? 'Admin Login' : 
                 currentStep === 'otp' ? 'Email Verification' :
                 currentStep === 'forgot-email' ? 'Forgot Password' :
                 currentStep === 'forgot-otp' ? 'Verify Email' :
                 currentStep === 'forgot-reset' ? 'Reset Password' : 'Admin Login'}
              </h2>
              
              {/* Step Indicator */}
              <div className="flex items-center justify-center space-x-4 mb-4">
                <div className={`flex items-center ${currentStep === 'password' ? 'text-green-400' : 'text-green-500'}`}>
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center ${currentStep === 'password' ? 'bg-green-500' : 'bg-green-600'}`}>
                    <span className="text-white font-semibold">1</span>
                  </div>
                  <span className="ml-2 text-sm">Password</span>
                </div>
                <div className={`w-8 h-1 ${currentStep === 'otp' ? 'bg-green-500' : 'bg-white/30'}`}></div>
                <div className={`flex items-center ${currentStep === 'otp' ? 'text-green-400' : 'text-white/50'}`}>
                  <div className={`w-8 h-8 rounded-full flex items-center justify-center ${currentStep === 'otp' ? 'bg-green-500' : 'bg-white/30'}`}>
                    <span className="text-white font-semibold">2</span>
                  </div>
                  <span className="ml-2 text-sm">Email OTP</span>
                </div>
              </div>
            </div>

            {/* Error Message */}
            {error && (
              <div className="bg-red-500/20 border border-red-400 text-red-100 px-4 py-3 rounded-lg mb-4" role="alert">
                <span className="block sm:inline">{error}</span>
              </div>
            )}

            {/* Success Message */}
            {success && (
              <div className="bg-green-500/20 border border-green-400 text-green-100 px-4 py-3 rounded-lg mb-4" role="alert">
                <span className="block sm:inline">{success}</span>
              </div>
            )}

            {/* Step 1: Password Login */}
            {currentStep === 'password' && (
              <form className="space-y-4" onSubmit={handlePasswordLogin}>
                <div className="form-group">
                  <label htmlFor="usernameOrEmail" className="block text-sm font-medium mb-2">
                    Email
                  </label>
                  <input
                    type="text"
                    id="usernameOrEmail"
                    name="usernameOrEmail"
                    value={usernameOrEmail}
                    onChange={(e) => setUsernameOrEmail(e.target.value)}
                    required
                    className="w-full px-4 py-3 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60"
                    placeholder="Enter your username or email"
                  />
                </div>
                
                <div className="form-group relative">
                  <label htmlFor="password" className="block text-sm font-medium mb-2">
                    Password
                  </label>
                  <input
                    type={showPassword ? 'text' : 'password'}
                    id="password"
                    name="password"
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    required
                    className="w-full px-4 py-3 pr-12 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60"
                    placeholder="Enter your password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowPassword((prev) => !prev)}
                    className="absolute right-3 top-10 text-white/70 hover:text-white"
                  >
                    {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>

                <div className="text-right">
                  <button 
                    type="button" 
                    onClick={handleForgotPassword}
                    className="text-sm text-white/70 hover:text-white underline"
                  >
                    Forgot Password?
                  </button>
                </div>

                <button 
                  type="submit" 
                  disabled={loading} 
                  className="w-full py-3 mt-6 bg-green-500 hover:bg-green-600 disabled:bg-green-500/50 border-2 border-green-600 hover:border-green-700 rounded-lg font-semibold text-white transition-colors duration-200 flex items-center justify-center"
                >
                  {loading ? (
                    <>
                      <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2 Th"></div>
                      Verifying credentials...
                    </>
                  ) : (
                    'Continue'
                  )}
                </button>
              </form>
            )}

            {/* Step 2: OTP Verification */}
            {currentStep === 'otp' && (
              <div className="space-y-4">
                <div className="text-center mb-4">
                  <div className="bg-blue-500/20 border border-blue-400 text-blue-100 px-4 py-3 rounded-lg text-sm">
                    <Mail className="w-4 h-4 inline mr-2" />
                    Verification code sent to: <strong>{email}</strong>
                  </div>
                </div>

                <form onSubmit={handleVerifyOTP}>
                  <div className="form-group">
                    <label htmlFor="otp" className="block text-sm font-medium mb-2 text-center">
                      <Shield className="w-4 h-4 inline mr-2" />
                      Enter 6-Digit Verification Code
                    </label>
                    <input
                      type="text"
                      id="otp"
                      name="otp"
                      value={otp}
                      onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      required
                      maxLength={6}
                      className="w-full px-4 py-4 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60 text-center text-3xl font-mono tracking-widest"
                      placeholder="000000"
                      autoComplete="one-time-code"
                    />
                  </div>

                  {countdown > 0 && (
                    <div className="text-center text-sm text-white/70 mb-4">
                      <Clock className="w-4 h-4 inline mr-1" />
                      Code expires in: <span className="font-mono text-green-400">{Math.floor(countdown / 60)}:{(countdown % 60).toString().padStart(2, '0')}</span>
                    </div>
                  )}

                  {/* Resend OTP Button */}
                  <div className="text-center mb-4">
                    <button 
                      type="button" 
                      onClick={handleResendOTP}
                      disabled={loading || resendCountdown > 0}
                      className="text-sm text-white/70 hover:text-white underline disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {loading ? 'Resending...' : 
                       resendCountdown > 0 ? `Resend available in ${resendCountdown}s` : 
                       'Resend verification code'}
                    </button>
                  </div>

                  <div className="flex space-x-3 mt-6">
                    <button 
                      type="button" 
                      onClick={backToPasswordStep}
                      className="flex-1 py-3 bg-gray-500 hover:bg-gray-600 border-2 border-gray-600 hover:border-gray-700 rounded-lg font-semibold text-white transition-colors duration-200"
                    >
                      Back
                    </button>
                    <button 
                      type="submit" 
                      disabled={loading || otp.length !== 6} 
                      className="flex-1 py-3 bg-green-500 hover:bg-green-600 disabled:bg-green-500/50 border-2 border-green-600 hover:border-green-700 disabled:border-green-500/50 rounded-lg font-semibold text-white transition-colors duration-200 flex items-center justify-center"
                    >
                      {loading ? (
                        <>
                          <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                          Verifying...
                        </>
                      ) : (
                        'Complete Login'
                      )}
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Step 3: Forgot Password - Email Input */}
            {currentStep === 'forgot-email' && (
              <form className="space-y-4" onSubmit={handleSendForgotPasswordOTP}>
                <div className="text-center mb-4">
                  <p className="text-white/80 text-sm">
                    Enter your email address and we'll send you a verification code to reset your password.
                  </p>
                </div>

                <div className="form-group">
                  <label htmlFor="forgotEmail" className="block text-sm font-medium mb-2">
                    <Mail className="w-4 h-4 inline mr-2" />
                    Email Address
                  </label>
                  <input
                    type="email"
                    id="forgotEmail"
                    name="forgotEmail"
                    value={forgotEmail}
                    onChange={(e) => setForgotEmail(e.target.value)}
                    required
                    className="w-full px-4 py-3 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60"
                    placeholder="Enter your email address"
                  />
                </div>

                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={backToLogin}
                    className="flex-1 py-3 bg-gray-500 hover:bg-gray-600 border-2 border-gray-600 hover:border-gray-700 rounded-lg font-semibold text-white transition-colors duration-200"
                  >
                    Back to Login
                  </button>
                  <button 
                    type="submit" 
                    disabled={loading} 
                    className="flex-1 py-3 bg-green-500 hover:bg-green-600 disabled:bg-green-500/50 border-2 border-green-600 hover:border-green-700 disabled:border-green-500/50 rounded-lg font-semibold text-white transition-colors duration-200 flex items-center justify-center"
                  >
                    {loading ? (
                      <>
                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                        Sending...
                      </>
                    ) : (
                      'Send Code'
                    )}
                  </button>
                </div>
              </form>
            )}

            {/* Step 4: Forgot Password - OTP Verification */}
            {currentStep === 'forgot-otp' && (
              <div className="space-y-4">
                <div className="text-center mb-4">
                  <div className="bg-blue-500/20 border border-blue-400 text-blue-100 px-4 py-3 rounded-lg text-sm">
                    <Mail className="w-4 h-4 inline mr-2" />
                    Verification code sent to: <strong>{forgotEmail}</strong>
                  </div>
                </div>

                <form onSubmit={handleVerifyForgotPasswordOTP}>
                  <div className="form-group">
                    <label htmlFor="forgotOtp" className="block text-sm font-medium mb-2 text-center">
                      <Shield className="w-4 h-4 inline mr-2" />
                      Enter 6-Digit Verification Code
                    </label>
                    <input
                      type="text"
                      id="forgotOtp"
                      name="forgotOtp"
                      value={forgotOtp}
                      onChange={(e) => setForgotOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                      maxLength={6}
                      required
                      className="w-full px-4 py-3 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60 text-center text-2xl tracking-widest"
                      placeholder="000000"
                    />
                  </div>

                  {countdown > 0 && (
                    <div className="text-center text-white/70 text-sm mb-4">
                      <Clock className="w-4 h-4 inline mr-1" />
                      Code expires in {Math.floor(countdown / 60)}:{(countdown % 60).toString().padStart(2, '0')}
                    </div>
                  )}

                  {/* Resend OTP Button for Forgot Password */}
                  <div className="text-center mb-4">
                    <button 
                      type="button" 
                      onClick={handleResendForgotPasswordOTP}
                      disabled={loading || forgotResendCountdown > 0}
                      className="text-sm text-white/70 hover:text-white underline disabled:opacity-50 disabled:cursor-not-allowed"
                    >
                      {loading ? 'Resending...' : 
                       forgotResendCountdown > 0 ? `Resend available in ${forgotResendCountdown}s` : 
                       'Resend verification code'}
                    </button>
                  </div>

                  <div className="flex gap-3">
                    <button
                      type="button"
                      onClick={backToLogin}
                      className="flex-1 py-3 bg-gray-500 hover:bg-gray-600 border-2 border-gray-600 hover:border-gray-700 rounded-lg font-semibold text-white transition-colors duration-200"
                    >
                      Back to Login
                    </button>
                    <button 
                      type="submit" 
                      disabled={loading || forgotOtp.length !== 6} 
                      className="flex-1 py-3 bg-green-500 hover:bg-green-600 disabled:bg-green-500/50 border-2 border-green-600 hover:border-green-700 disabled:border-green-500/50 rounded-lg font-semibold text-white transition-colors duration-200 flex items-center justify-center"
                    >
                      {loading ? (
                        <>
                          <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                          Verifying...
                        </>
                      ) : (
                        'Verify Code'
                      )}
                    </button>
                  </div>
                </form>
              </div>
            )}

            {/* Step 5: Forgot Password - Reset Password */}
            {currentStep === 'forgot-reset' && (
              <form className="space-y-4" onSubmit={handleResetPassword}>
                <div className="text-center mb-4">
                  <p className="text-white/80 text-sm">
                    Create a new password for your account. Make sure it's at least 8 characters long.
                  </p>
                </div>

                <div className="form-group relative">
                  <label htmlFor="newPassword" className="block text-sm font-medium mb-2">
                    New Password
                  </label>
                  <input
                    type={showNewPassword ? 'text' : 'password'}
                    id="newPassword"
                    name="newPassword"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                    minLength={8}
                    className="w-full px-4 py-3 pr-12 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60"
                    placeholder="Enter new password (min 8 characters)"
                  />
                  <button
                    type="button"
                    onClick={() => setShowNewPassword((prev) => !prev)}
                    className="absolute right-3 top-10 text-white/70 hover:text-white"
                  >
                    {showNewPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>

                <div className="form-group relative">
                  <label htmlFor="confirmPassword" className="block text-sm font-medium mb-2">
                    Confirm New Password
                  </label>
                  <input
                    type={showConfirmPassword ? 'text' : 'password'}
                    id="confirmPassword"
                    name="confirmPassword"
                    value={confirmPassword}
                    onChange={(e) => setConfirmPassword(e.target.value)}
                    required
                    minLength={8}
                    className="w-full px-4 py-3 pr-12 rounded-lg bg-white/10 border border-white/30 focus:outline-none focus:ring-2 focus:ring-green-400 focus:border-transparent placeholder-white/60"
                    placeholder="Confirm new password"
                  />
                  <button
                    type="button"
                    onClick={() => setShowConfirmPassword((prev) => !prev)}
                    className="absolute right-3 top-10 text-white/70 hover:text-white"
                  >
                    {showConfirmPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                  </button>
                </div>

                <div className="flex gap-3">
                  <button
                    type="button"
                    onClick={backToLogin}
                    className="flex-1 py-3 bg-gray-500 hover:bg-gray-600 border-2 border-gray-600 hover:border-gray-700 rounded-lg font-semibold text-white transition-colors duration-200"
                  >
                    Back to Login
                  </button>
                  <button 
                    type="submit" 
                    disabled={loading || !newPassword || !confirmPassword} 
                    className="flex-1 py-3 bg-green-500 hover:bg-green-600 disabled:bg-green-500/50 border-2 border-green-600 hover:border-green-700 disabled:border-green-500/50 rounded-lg font-semibold text-white transition-colors duration-200 flex items-center justify-center"
                  >
                    {loading ? (
                      <>
                        <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
                        Resetting...
                      </>
                    ) : (
                      'Reset Password'
                    )}
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      </section>
    </main>
  );
};

export default LoginForm;