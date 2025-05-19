
// LoginForm.tsx
import React, { useState } from 'react';
import { Eye, EyeOff } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const LoginForm: React.FC = () => {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const { login } = useAuth();

  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    if (!username || !password) {
      setError('Username and password are required');
      setLoading(false);
      return;
    }

    try {
      // Use the login function from AuthContext correctly
      const success = await login(username, password);
      
      if (success) {
        console.log('Login successful, attempting to navigate to dashboard');
        navigate('/dashboard');
        console.log('Navigation function called');
      } else {
        setError('Invalid username or password');
      }
    } catch (err: any) {
      console.error('Login failed:', err);
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="bg-white">
      <section className="bg-[url(/images/background.png)] relative min-h-screen bg-cover bg-center flex flex-col items-center justify-center px-4 md:px-10">
        <div className="mt-10 md:mt-10 flex flex-col items-center justify-center z-10 space-y-6 pt-0 pb-20">
          <div>
            <img
              src="/images/loginsignuplogo.png"
              alt="Maize Watch Text"
              className="w-60 md:w-80 lg:w-160"
            />
          </div>
          <div className="login-form w-full max-w-xl bg-white/10 backdrop-blur-md rounded-2xl p-6 sm:p-8 text-white shadow-lg">
            <h2 className="text-2xl md:text-3xl font-bold text-center mb-6">Login</h2>
            {error && <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">
              <span className="block sm:inline">{error}</span>
            </div>}
            
            <form onSubmit={handleSubmit}>
              <div className="form-group">
                <label htmlFor="username">Username</label>
                <input
                  type="text"
                  id="username"
                  name="username"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  required
                  className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Enter your username"
                />
              </div>
              
              <div className="form-group relative">
                <label htmlFor="password">Password</label>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="password"
                  name="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="w-full px-4 py-2 pr-10 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                  placeholder="Enter your password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((prev) => !prev)}
                  className="absolute right-3 top-9 text-white"
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              </div>
              
              <button 
                type="submit" 
                disabled={loading} 
                className="w-full py-2 mt-4 bg-green-500 hover:bg-green-600 rounded-full font-semibold text-white bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in duration-250"
              >
                {loading ? 'Logging in...' : 'Login'}
              </button>
            </form>
          </div>
        </div>
      </section>
    </main>
  );
};

export default LoginForm;