import { useNavigate } from 'react-router-dom';
import { useEffect } from 'react';
import { useLocation } from 'react-router-dom';

export default function ProductPage() {
  const navigate = useNavigate();
  const { pathname } = useLocation();

  useEffect(() => {
    window.scrollTo(0, 0);
  }, [pathname]);
  return (
    <>
      <body className="bg-[#E6F0D3] min-h-screen">
        <main>
          <div className=" relative h-10 bg-cover bg-center flex items-center justify-center">
            <nav className="bg-(--color-dgreen) fixed top-0 w-full container z-10 bg-transparent backdrop-blur-[3px] px-2 md:px-10 py-1 flex items-center justify-between">
              <div className="w-16 md:w-20 py-2 flex items-center">
                <img
                  src="/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover"
                />
              </div>
              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/signup')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in duration-250">Sign Up</button></li>
                  <li><button>
                    <img
                      src="/images/menu-green.png"
                      alt="Logo"
                      className="h-8 w-8 md:h-10 md:w-10 object-cover hover:opacity-80 duration-300"
                    />
                  </button></li>
                </ul>
              </div>
            </nav>
          </div>

          <section className="py-16 px-4 md:px-20 mr-5">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="p-2 ">
                    <img src="/images/header-product.png" alt="Brain Icon" className="w-full h-full" />
                  </div>
                </div>
                <p className="pt-5">
                  Maize Watch offers a real-time, IoT-powered mobile and web application designed to revolutionize corn farming by turning raw environmental data into actionable insights. Using a network of smart sensors—monitoring temperature, humidity, soil moisture, light intensity, and soil pH—our system collects critical information from the field and transmits it instantly to the cloud via a SIM-enabled microcontroller.
                </p>
                <div className="flex items-center md:gap-90  ">
                  <button onClick={() => navigate('/products')} className="flex items-center gap-2 text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) pb-1 cursor-pointer">
                    LEARN MORE
                    <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-5 w-350 mx-auto" />

          {/* See the prototype */}
          <section className="py-16 px-4 md:px-20 mr-5">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="p-2 ">
                    <img src="/images/header-product-2.png" alt="Brain Icon" className="w-full h-full" />
                  </div>

                </div>
              </div>
            </div>
          </section>

          <hr className="my-4 border-t border-(--color-lgreen) mt-5 w-350 mx-auto" />

          <section className="bg-[#E6F0D3] py-12 px-4 md:px-20">
            <div className="max-w-5xl mx-auto space-y-6 text-center">
              <h2 className="text-3xl md:text-4xl font-bold text-(--color-dgreen)">Learn and Grow.</h2>

              <div className="flex flex-col items-center space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 bg-white rounded-xl overflow-hidden shadow-md max-w-3xl w-full">
                  <div className="bg-(--color-dgreen) text-white p-6 flex items-center justify-center">
                    <p className="text-lg font-semibold text-center">Want to understand how the app works?</p>
                  </div>
                  <div className="bg-(--color-lgreen) text-white p-6 flex items-center justify-center">
                    <p className="text-sm md:text-base text-center">
                      Navigate through our <span className="underline">knowledge hub</span>, just click the learn more below.
                    </p>
                  </div>
                </div>

                <button
                  onClick={() => navigate('/technology')}
                  className="flex items-center gap-2 text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) pb-1 cursor-pointer"
                >
                  LEARN MORE
                  <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                  </svg>
                </button>
              </div>
            </div>
          </section>


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