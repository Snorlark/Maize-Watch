
import { useNavigate } from 'react-router-dom'
import { Eye, EyeOff } from 'lucide-react'
import React, { useState } from 'react'

export default function SignUpPage() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  return (
    <main className="bg-white">
      <section className="bg-[url(/images/background.png)] relative min-h-screen bg-cover bg-center flex flex-col items-center justify-center px-4 md:px-10">
        {/* Navbar */}
        {/* <nav className="bg-green-800/70 fixed top-0 w-full z-10 backdrop-blur-md px-4 md:px-10 py-3 flex items-center justify-between text-white">
          <div className="flex items-center space-x-2">
            <img
              src="/images/smalllogo.png"
              alt="Logo"
              className="h-12 w-12 md:h-16 md:w-16 object-cover"
            />
            <p className="text-lg md:text-xl font-bold">Maize Watch</p>
          </div>
          <ul className="flex space-x-4 md:space-x-10 font-bold">
            <li><button className="hover:text-green-300">Contact</button></li>
            <li><button className="hover:text-green-300">Login</button></li>
          </ul>
        </nav> */}

        {/* Background Logo */}
        {/* <div className="fixed bottom-0 left-0 p-2 z-0">
          <img src="/images/biglogo.png" alt="Maize Watch Logo" className="w-60 md:w-80 lg:w-160" />
        </div> */}

        {/* Header Logo */}
        <div className="mt-5 md:mt-5 flex flex-col items-center justify-center z-10 space-y-6  pt-0 pb-20">
          {/* Header Logo */}
          <div>
            <img
              src="/images/loginsignuplogo.png"
              alt="Maize Watch Text"
              className="w-60 md:w-80 lg:w-160"
            />
          </div>

          {/* Sign Up Card */}
          {/* w-full max-w-xl */}
          <div className=" bg-white/10 backdrop-blur-md rounded-2xl p-6 sm:p-8 text-white shadow-lg mt-4 md:mt-5 mx-auto w-full max-w-[320px] lg:max-w-full">
            <h2 className="text-2xl md:text-3xl font-bold text-center mb-6">Sign Up</h2>
            <form className="space-y-4">
              <div className="flex flex-col md:flex-row md:space-x-4 space-y-4 md:space-y-0">
                <div className="w-full">
                  <label className="block mb-1 text-sm font-medium">First Name</label>
                  <input
                    type="text"
                    className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                  />
                </div>
                <div className="w-full">
                  <label className="block mb-1 text-sm font-medium">Last Name</label>
                  <input
                    type="text"
                    className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                  />
                </div>
              </div>
              <div>
                <label className="block mb-1 text-sm font-medium">E-Mail Address</label>
                <input
                  type="email"
                  className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                />
              </div>
              <div className="relative">
                <label className="block mb-1 text-sm font-medium">Password</label>
                <input
                  type={showPassword ? 'text' : 'password'}
                  className="w-full px-4 py-2 pr-10 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((prev) => !prev)}
                  className="absolute right-3 top-9 text-white"
                >
                  {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>
              </div>

              {/* Confirm Password */}
              <div className="relative mt-4">
                <label className="block mb-1 text-sm font-medium">Confirm Password</label>
                <input
                  type={showConfirm ? 'text' : 'password'}
                  className="w-full px-4 py-2 pr-10 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                />
                <button
                  type="button"
                  onClick={() => setShowConfirm((prev) => !prev)}
                  className="absolute right-3 top-9 text-white"
                >
                  {showConfirm ? <EyeOff size={20} /> : <Eye size={20} />}
                </button>


                <div className="relative mt-4">
                  <input
                    id="link-checkbox"
                    type="checkbox"
                    value=""
                    className="w-4 h-4 text-blue-600 bg-gray-100 border-gray-300 rounded-sm focus:ring-blue-500 dark:focus:ring-blue-600 dark:ring-offset-gray-800 focus:ring-2 dark:bg-gray-700 dark:border-gray-600"
                  />
                  <label
                    htmlFor="link-checkbox"
                    className="ms-2 text-sm font-medium text-gray-900 dark:text-gray-300"
                  >
                    I agree with the{" "}
                    <a
                      href="#"
                      className="text-blue-600 dark:text-blue-500 hover:underline"
                    >
                      terms and conditions
                    </a>
                    .
                  </label>
                </div>
              </div>
              <button
                type="submit"
                onClick={() => navigate('/login')}
                className="w-full py-2 mt-2 bg-green-500 hover:bg-green-600 rounded-full font-semibold text-white bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in duration-250"
              >
                Sign Up
              </button>
            </form>
          </div>
          <p className='text-white'>Already have an Account? <u onClick={() => navigate('/auth/login')} className="cursor-pointer hover:text-blue-400">Log in here</u></p>
        </div>
      </section>
    </main>
  );
}
