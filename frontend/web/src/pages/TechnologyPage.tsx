import { useNavigate } from 'react-router-dom';

export default function TechnologyPage() {
    const navigate = useNavigate();
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
                    <img src="/images/header-technology.png" alt="Brain Icon" className="w-full h-full" />
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
                </main>

            </body>
        </>
    )
}