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
                            className="flex items-center  text-lg font-semibold text-(--color-dgreen) border-b-2 border-(--color-dgreen) hover:border-(--color-lgreen) hover:text-(--color-lgreen) transition-all ease-in-out duration-300 cursor-pointer"
                          >
                            {isOpen ? "LESS -" : "MORE +"}
                          </button>


                          {isOpen && (
                            <div className="pt-5 text-(--color-dgreen)">

                              <div>
                              <h3 className="text-2xl md:text-3xl xl:mt-5 font-bold ">Microcontrollers </h3>
                                <p className="text-sm xl:py-8 md:text-base leading-relaxed list-disc">
                                  <li><span className="font-bold">ESP 32 </span> – The ESP-32 Development Board is a compact yet powerful solution, primarily designed to enable seamless wireless connectivity (Wi-Fi and Bluetooth) for prototyping IoT and various other applications. Featuring a dual-mode ESP32 microcontroller operating at 2.4 GHz, it delivers high performance with ultra-low power consumption.</li>
                                </p>
                              
                                <h3 className="text-2xl md:text-3xl xl:mt-5 font-bold ">Sensors Used</h3>
                                <p className="text-sm xl:py-8 md:text-base leading-relaxed list-disc">
                                  <li><span className="font-bold">Temperature and Humidity Sensor </span> – The DHT11 Sensor is a fundamental digital sensor for measuring ambient temperature and humidity. Employing a capacitive humidity sensor and a thermistor, it outputs readings as a digital signal via a single data pin, simplifying integration by eliminating the need for analog inputs.</li>
                                  <li><span className="font-bold">Soil Moisture Sensor</span> – This analog capacitive soil moisture sensor utilizes capacitive sensing technology to measure soil moisture levels, offering an alternative to traditional resistive methods. Constructed from corrosion-resistant materials, it ensures extended operational lifespan.  </li>
                                  <li><span className="font-bold">Light-Dependent Control Sensor </span> – The LM393 Photosensitive Light-Dependent Control Sensor LDR Module is using a high-quality LM393 voltage comparator. Easy to install using the sensitive type photosensitive resistance sensor the comparator output signal gives a clean and good waveform. </li>
                                  <li><span className="font-bold">Soil pH Sensor </span> – The RS485 Output 2Pin Probes Soil PH Sensor helps you get accurate and dependable readings of the pH level in soil. It's designed for farming and environmental uses. Instead of regular connections, it uses a special type called RS485, which sends data clearly even over longer distances. </li>
                                </p>
                              </div>

                              </div>
                            )}
                          </div>
                        </div>
                      </div>
                    </div>

          <hr className="my-4 border-t border-(--color-lgreen) mt-10  mx-10 xl:mx-40" />

              <div className="container mx-auto py-15 2xl:px-40 ">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-2 items-center">
                  

                <div className="relative flex pb-8 justify-center items-center">
                    <div className="bg-(--color-lgreen) w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-50 transition-discrete ease-in-out duration-500"></div>
                    <img
                      src="/images/IoT.png"
                      alt="Maize Watch App Preview"
                      className="relative w-[300px] md:w-[320px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                    />
                </div>


                  <div className="px-10  mx-auto ">
                    <div className="flex items-center gap-2">
                      <div >
                        <h2 className="text-5xl md:text-4xl pb-2 font-bold text-(--color-dgreen)">Keep an eye on your corn crops in real time with our IoT sensors. </h2>
                      </div>
                    </div>
  
                    <p className=" xl:py-8 text-sm md:text-base xl:text-lg max-w-xl">
                    Track temperature, soil moisture, humidity, pH level, and light intensity using affordable, reliable, and durable sensors. All data is sent straight to a user-friendly app, giving you real-time updates on your field conditions. Make faster, smarter decisions on irrigation, soil care, and crop management to help your crops grow healthier and boost your harvest.                    </p>
                    
                      
                  </div>
                  
                  
                </div>
              </div>

              <div className="container mx-auto py-15 2xl:px-40 ">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-2 items-center">
                  <div className="px-10  mx-auto ">
                    <div className="flex items-center gap-2">
                      <div >
                        <h2 className="text-5xl md:text-4xl pb-2 font-bold text-(--color-dgreen)">Get easy-to-follow advices with the prescription checklist.</h2>
                      </div>
                    </div>
  
                    <p className=" xl:py-8 text-sm md:text-base xl:text-lg max-w-xl">
                    Based on real-time data from your field, the app gives you clear, simple action steps to take care of your crops. Everything is laid out in a checklist, so you can easily see what needs to be done, when to water, when to check your soil, and how to manage your crops better.</p>
                  </div>
                  

                  <div className="pt-8 relative flex justify-center items-center">
                    <div className="bg-(--color-lgreen) w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-50 transition-discrete ease-in-out duration-500"></div>
                    <img
                      src="/images/prescriptive.png"
                      alt="Maize Watch App Preview"
                      className="relative w-[300px] md:w-[320px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                    />
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