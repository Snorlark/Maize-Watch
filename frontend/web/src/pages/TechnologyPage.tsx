import { useNavigate } from 'react-router-dom';
import { useState } from "react";

export default function TechnologyPage() {
    const navigate = useNavigate();
    const [isOpen, setIsOpen] = useState(false);

    return (
        <>
            <body className="bg-(--color-white) min-h-screen">
                <main>
                    <div className=" relative h-10 bg-cover bg-center flex items-center justify-center">
                        <nav className="bg-(--color-dgreen) fixed top-0 w-full container z-10 bg-transparent backdrop-blur-[3px] px-2 md:px-10 py-1 flex items-center justify-between">
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
                                            src="/images/menu-green.png"
                                            alt="Logo"
                                            className="h-8 w-8 md:h-10 md:w-10 object-cover hover:opacity-80 duration-300"
                                        />
                                    </button></li>
                                </ul>
                            </div>
                        </nav>
                    </div>

            <div className="py-16 px-4 md:px-20 2xl:pt-20 mr-5">
            <div className="container mx-auto px-4 md:px-20 lg:px-80">
              <div className=" space-y-6">
                <div className="flex items-center gap-3">
                  <div className="p-2 ">
                    <img src="/images/header-technology.png" alt="Brain Icon" className="w-full h-full" />
                  </div>
                </div >
                  <p className="py-2 xl:text-lg mt-10">
                    This system would be accessible through a mobile app that displays real-time data from the Arduino sensors, prompts alerts, and provides prescriptive analytics. The system uses an Arduino board and various sensors such as temperature and humidity sensor, soil moisture sensor, LDR (light dependent resistor) sensor, and pH level sensor which are vital factors to the growth of a corn crop. 
                  </p>
                  <p className="py-2 xl:text-lg mb-10">
                    The collected data from the sensors and with the use of a random forest algorithm would be used to generate a recommendation to the user, providing users recommendations on what actions to perform to further improve the productivity of the crop with its current state.
                  </p>
                <div className="items-center">


                  <button
                    onClick={() => setIsOpen(!isOpen)}
                    className="flex items-center  text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1 cursor-pointer"
                  >
                    {isOpen ? "LESS -" : "MORE +"}
                  </button>


                  {isOpen && (
                    <div className="py-5 text-(--color-dgreen)">

                      <div>
                        <h3 className="text-2xl md:text-3xl xl:mt-5 font-bold ">Sensors Used</h3>
                        <p className="text-sm xl:py-8 md:text-base leading-relaxed list-disc">
                          <li><span className="font-bold">Sensor1 </span> – Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. </li>
                          <li><span className="font-bold">Sensor2 </span> – Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. </li>
                          <li><span className="font-bold">Sensor3 </span> – Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. </li>
                          <li><span className="font-bold">Sensor4 </span> – Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. </li>
                        </p>
                      </div>

                    </div>
                  )}




                </div>
              </div>
            </div>
          </div>

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

                </main>

            </body>
        </>
    )
}