import { useNavigate } from 'react-router-dom'
import { Eye, EyeOff } from 'lucide-react'
import React, { useState } from 'react';
import authService, { RegisterPayload } from '../../api/services/authService';

const RegisterForm: React.FC = () => {
    const navigate = useNavigate();
    const [showPassword, setShowPassword] = useState(false);
    const [showConfirm, setShowConfirm] = useState(false);
    const [formData, setFormData] = useState<RegisterPayload>({
        username: '',
        password: '',
        fullName: '',
        contactNumber: '',
        address: ''
    });
    const [errors, setErrors] = useState<string>('');
    const [success, setSuccess] = useState<string>('');
    const [loading, setLoading] = useState<boolean>(false);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const { name, value } = e.target;
        setFormData({
            ...formData,
            [name]: value
        });
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setErrors('');
        setSuccess('');

        // Simple validation
        if (!formData.username || !formData.password || !formData.fullName ||
            !formData.contactNumber || !formData.address) {
            setErrors('All fields are required');
            setLoading(false);
            return;
        }

        if (formData.password.length < 6) {
            setErrors('Password must be at least 6 characters');
            setLoading(false);
            return;
        }

        // Philippine phone number validation
        const phoneRegex = /^(09\d{9}|\+639\d{9})$/;
        if (!phoneRegex.test(formData.contactNumber)) {
            setErrors('Please enter a valid Philippine mobile number');
            setLoading(false);
            return;
        }

        try {
            const response = await authService.register(formData);

            if (response.success) {
                setSuccess('Registration successful! You can now login.');
                // Reset form
                setFormData({
                    username: '',
                    password: '',
                    fullName: '',
                    contactNumber: '',
                    address: ''
                });
                navigate('/login');
            } else {
                setErrors(response.message || 'Registration failed');
            }
        } catch (error) {
            setErrors('Something went wrong. Please try again later.');
        } finally {
            setLoading(false);
        }
    };

    return (
        // <div className="register-form">
        //   <h2>Register</h2>
        //   {errors && <div className="error-message">{errors}</div>}
        //   {success && <div className="success-message">{success}</div>}

        //   <form onSubmit={handleSubmit}>
        //     <div className="form-group">
        //       <label htmlFor="username">Username</label>
        //       <input
        //         type="text"
        //         id="username"
        //         name="username"
        //         value={formData.username}
        //         onChange={handleChange}
        //         required
        //       />
        //     </div>

        //     <div className="form-group">
        //       <label htmlFor="password">Password</label>
        //       <input
        //         type="password"
        //         id="password"
        //         name="password"
        //         value={formData.password}
        //         onChange={handleChange}
        //         required
        //       />
        //       <small>Password must be at least 6 characters</small>
        //     </div>

        //     <div className="form-group">
        //       <label htmlFor="fullName">Full Name</label>
        //       <input
        //         type="text"
        //         id="fullName"
        //         name="fullName"
        //         value={formData.fullName}
        //         onChange={handleChange}
        //         required
        //       />
        //     </div>

        //     <div className="form-group">
        //       <label htmlFor="contactNumber">Contact Number</label>
        //       <input
        //         type="text"
        //         id="contactNumber"
        //         name="contactNumber"
        //         value={formData.contactNumber}
        //         onChange={handleChange}
        //         placeholder="e.g., 09123456789 or +639123456789"
        //         required
        //       />
        //     </div>

        //     <div className="form-group">
        //       <label htmlFor="address">Address</label>
        //       <input
        //         type="text"
        //         id="address"
        //         name="address"
        //         value={formData.address}
        //         onChange={handleChange}
        //         required
        //       />
        //     </div>

        //     <button type="submit" disabled={loading}>
        //       {loading ? 'Registering...' : 'Register'}
        //     </button>
        //   </form>
        // </div>

        <main className="bg-white">
            <section className="bg-[url(/images/background.png)] relative min-h-screen bg-cover bg-center flex flex-col items-center justify-center px-4 md:px-10">

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
                        {errors && <div className="error-message">{errors}</div>}
                        {success && <div className="success-message">{success}</div>}
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div className="flex flex-col md:flex-row md:space-x-4 space-y-4 md:space-y-0">
                                <div className="w-full">
                                    <label className="block mb-1 text-sm font-medium">Username</label>
                                    <input
                                        type="text"
                                        name="username"
                                        placeholder="username"
                                        value={formData.username}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                                    />
                                </div>
                                <div className="w-full">
                                    <label className="block mb-1 text-sm font-medium">Password</label>
                                    <input
                                        type={showPassword ? 'text' : 'password'}
                                        id="password"
                                        name="password"
                                        value={formData.password}
                                        onChange={handleChange}
                                        required
                                        className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                                    />
                                    <button
                                        type="button"
                                        onClick={() => setShowPassword((prev) => !prev)}
                                        className="absolute right-3 top-9 text-white"
                                    >
                                        {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
                                    </button>
                                </div>
                            </div>

                            <div>
                                <label className="block mb-1 text-sm font-medium">Full Name</label>
                                <input
                                    type="text"
                                    id="fullName"
                                    name="fullName"
                                    placeholder="Juan Dela Cruz"
                                    value={formData.fullName}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-4 py-2 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                                />
                            </div>

                            <div className="relative">
                                <label className="block mb-1 text-sm font-medium">Contact Number</label>
                                <input
                                    type="text"
                                    id="contactNumber"
                                    name="contactNumber"
                                    value={formData.contactNumber}
                                    onChange={handleChange}
                                    placeholder="e.g., 09123456789 or +639123456789"
                                    required
                                    className="w-full px-4 py-2 pr-10 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                                />
                            </div>

                            <div className="relative mt-4">
                                <label className="block mb-1 text-sm font-medium">Address</label>
                                <input
                                    type="text"
                                    id="address"
                                    name="address"
                                    value={formData.address}
                                    onChange={handleChange}
                                    required
                                    className="w-full px-4 py-2 pr-10 rounded-md bg-transparent border border-white/40 focus:outline-none focus:ring-2 focus:ring-green-400"
                                />


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
                                disabled={loading}
                                className="w-full py-2 mt-2 bg-green-500 hover:bg-green-600 rounded-full font-semibold text-white bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in duration-250"
                            >
                                {loading ? 'Registering...' : 'Register'}
                            </button>
                        </form>
                    </div>
                    <p className='text-white'>Already have an Account? <u onClick={() => navigate('/login')} className="cursor-pointer hover:text-blue-400">Log in here</u></p>
                </div>
            </section>
        </main>
    );
};

export default RegisterForm;