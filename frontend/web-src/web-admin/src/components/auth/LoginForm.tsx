
// LoginForm.tsx
import React, { useState, useEffect } from 'react';
import { Eye, EyeOff, Mail, Shield, Clock } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

type LoginStep = 'password' | 'otp';

const LoginForm: React.FC = () => {
  const navigate = useNavigate();
  const ADMIN_PATH = import.meta.env.VITE_ADMIN_PATH || 'admin-portal-xyz123';
  const [showPassword, setShowPassword] = useState(false);
  const { login, verifyOTP } = useAuth();

  // Form states
  const [currentStep, setCurrentStep] = useState<LoginStep>('password');
  const [usernameOrEmail, setUsernameOrEmail] = useState('');
  const [password, setPassword] = useState('');
  const [email, setEmail] = useState('');
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  
  // OTP specific states
  const [countdown, setCountdown] = useState<number>(300); // 5 minutes

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
          console.log('Setting email for OTP step:', emailFromResponse);
          setEmail(emailFromResponse);
          setCurrentStep('otp');
          setCountdown(300); // 5 minutes
          setSuccess(result.message || 'Verification code sent to your email');
        } else {
          // Regular user - complete login
          console.log('Login successful, navigating to dashboard');
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
        console.log('OTP verification successful, navigating to dashboard');
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
    setError('');
    setSuccess('');
  };

  return (
    <main className="bg-white">
      <section className="bg-[url(/web-admin/public/images/background.png)] relative min-h-screen bg-cover bg-center flex flex-col items-center justify-center px-4 md:px-10">
        <div className="mt-10 md:mt-10 flex flex-col items-center justify-center z-10 space-y-6  pt-0 pb-20">
          <div>
            <img
              src="/web-admin/public/images/loginsignuplogo.png"
              alt="Maize Watch Text"
              className="w-60 md:w-80 lg:w-160"
            />
          </div>
          <div className="login-form w-full max-w-xl bg-white/10 backdrop-blur-md rounded-2xl p-6 sm:p-8 text-white shadow-lg">
            <div className="text-center mb-6">
              <h2 className="text-2xl md:text-3xl font-bold mb-4">
                {currentStep === 'password' ? 'Admin Login' : 'Email Verification'}
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
                  <button type="button" className="text-sm text-white/70 hover:text-white underline">
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
          </div>
        </div>
      </section>
    </main>
  );
};

export default LoginForm;