import { useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

export default function SolutionsPage() {
  const navigate = useNavigate();
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);

  
  return (
    <>
      <body className="bg-(--color-white) min-h-screen">
        <main>
          <div className=" relative h-10 bg-cover bg-center flex items-center justify-center">
            <nav className="bg-(--color-dgreen) fixed top-0 w-full container z-10 bg-transparent  px-2 md:px-10 py-1 flex items-center justify-between">
              <div className="w-16 md:w-20 py-2 flex items-center">
                <img
                  onClick={() => navigate('/')}
                  src="/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover cursor-pointer ease-in-out duration-250 hover:scale-110"
                />
              </div>
              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/signup')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in duration-250">Sign Up</button></li>
                  <li><button>
                    <img
                      onClick={() => navigate('/headermenu')}
                      src="/images/menu-green.png"
                      alt="Logo"
                      className="h-8 w-8 md:h-10 md:w-10 object-cover hover:opacity-80 duration-300"
                    />
                  </button></li>
                </ul>
              </div>
            </nav>
          </div>

          <section className="py-16 px-4  2xl:pt-20  md:px-20 mr-5">
            <div className="container mx-auto">
              <div className="container mx-auto px-4 md:px-20 lg:px-80">
                <div className=" space-y-6">
                  <div className="flex items-center gap-3">
                    <div className="p-2 ">
                      <img src="/images/header-solutions.png" alt="Brain Icon" className="w-full h-full" />
                    </div>
                  </div>
                  <p className="pt-5">
                    Maize Watch is a smart farming system that monitors real-time corn field conditions using IoT sensors and delivers data-driven recommendations through AI-powered prescriptive analytics—helping farmers grow healthier crops, efficiently and sustainably.
                  </p>
                  <div className="flex items-center md:gap-90  ">
                    <button onClick={() => navigate('/products')} className="flex items-center gap-2 text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer">
                      LEARN MORE
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                      </svg>
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />

          <section className="py-16 px-4 md:px-20 ">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className="space-y-6">
                <div className="inline-block items-center gap-3">
                  <div className="pb-5">
                    <img src="/images/header-solutions-2.png" alt="Brain Icon" className="w-full h-full" />
                  </div>
                  
                  <div className='py-5'>
                    <div className="bg-[url('/images/container-solutions-2.png')] bg-cover bg-center text-white p-6 rounded-xl p-15">
                      <h1 className="text-2xl md:text-4xl font-bold mb-4">Our Mission.</h1>
                      <p className="text-sm md:text-base leading-relaxed">
                        Maize Watch is committed to redefining corn farming through the fusion of technology and agriculture. Our mission is to empower farmers—especially in rural and underserved regions—by giving them access to real-time insights and actionable guidance. Through IoT-powered environmental monitoring and AI-driven prescriptive analytics, we aim to turn raw field data into smart, data-backed decisions that boost yield, minimize waste, and conserve resources.
                      </p>
                    </div>
                  </div>
                  <div className='py-5'>
                    <div className="bg-[url('/images/container-solutions-2.png')] bg-cover bg-center text-white p-6 rounded-xl p-15">
                      <h1 className="text-2xl md:text-4xl font-bold mb-4">Our Principles.</h1>
                      <p className="text-sm md:text-base leading-relaxed list-disc">
                        <li><span className="font-bold">Precision Agriculture </span> – Optimize every farming decision using real-time environmental data and analytics.</li>
                        <li><span className="font-bold">Tech-Driven Accessibility </span> – Deliver advanced farming insights through user-friendly platforms accessible even in rural areas.</li>
                        <li><span className="font-bold">Sustainability First </span> – Encourage responsible use of natural resources while enhancing long-term yield and land health.</li>
                      </p>
                    </div>
                  </div>
                  <div className='py-5'>
                    <div className="bg-[url('/images/container-solutions-2.png')] bg-cover bg-center text-white p-6 rounded-xl p-15">
                      <h1 className="text-2xl md:text-4xl font-bold mb-4">Our Vision.</h1>
                      <p className="text-sm md:text-base leading-relaxed list-disc">
                        <li> <span className="font-bold">Innovation </span>– We continuously embrace emerging technologies to improve farming efficiency.</li>
                        <li><span className="font-bold">Empowerment </span>– We aim to give farmers control over their crops through clear, actionable data.</li>
                        <li><span className="font-bold">Reliability </span> – We stand by real-time accuracy and consistent performance in the field.</li>
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />

          <section className="py-12 px-4 md:px-20">
            <div className="max-w-6xl mx-auto grid grid-cols-1 md:grid-cols-2 gap-10 items-center px-4 md:px-20 lg:px-40">
              <div>
                <h2 className="text-6xl font-bold text-(--color-dgreen) mb-8">The Problem.</h2>
                <p className="text-gray-700 text-sm md:text-base leading-relaxed">
                  Traditional corn farming in rural areas often faces inefficiencies due to a lack of real-time field data, unpredictable climate conditions, and limited access to modern tools for decision-making. Farmers frequently rely on experience and intuition, which can lead to overuse or underuse of resources like water and fertilizer, reduced yields, and vulnerability to crop diseases or poor soil conditions. Additionally, smallholder farmers often lack access to agricultural experts or timely information, making it difficult to make informed choices about irrigation, fertilization, or planting schedules—ultimately impacting both productivity and sustainability.
                </p>
              </div>
              <div className="flex justify-center">
                <img
                  src="/images/farmer.png" 
                  alt="Farmer inspecting corn"
                  className="rounded-xl shadow-md w-full max-w-md object-cover"
                />
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />


          <footer className="bg-(--color-white) py-6 px-4 md:px-12">
            <div className="container mx-auto max-w-6xl">
              <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-8 md:gap-4">
                <div className="space-y-3">
                  <img src="/images/logo.png" alt="Maize Watch" className="h-10 md:h-12" />
                  <div className="ml-7 flex gap-3">

                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/instagram.png" alt="Instagram" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/github.png" alt="GitHub" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/linkedin.png" alt="LinkedIn" className="h-5 w-5" />
                    </a>
                    <a href="#" className="text-(--color-dgreen) hover:opacity-80 transition-all duration-300">
                      <img src="/images/x.png" alt="X" className="h-5 w-5" />
                    </a>
                  </div>
                </div>

                <div className="mt-2 md:mt-0">
                  <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Information</h4>
                  <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">Privacy</a></li>
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">Terms of Use</a></li>
                    <li><a href="#" className="hover:opacity-80 transition-all duration-300">About us</a></li>
                  </ul>
                </div>

                <div className="mt-2 md:mt-0">
                  <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Contact Us</h4>
                  <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                    <li>1234 Taft Avenue</li>
                    <li>Malate, Manila 1004 Philippines</li>
                    <li>Office: (02) 123-4567 (Mon-Fri)</li>
                  </ul>
                </div>

                <div className="text-left md:text-right text-(--color-dgreen) text-xs md:text-sm mt-4 md:mt-12">
                  © 2025 NOVU. All rights reserved.
                </div>
              </div>
            </div>
          </footer>
          <br />
        </main>
      </body>
    </>
  )
}