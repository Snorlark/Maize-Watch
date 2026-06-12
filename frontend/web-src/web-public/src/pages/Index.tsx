
// import 'aos/dist/aos.css';
import { useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';
import AOS from 'aos';
import { X } from "lucide-react";

export default function Index() {
  const navigate = useNavigate();
  const [currentImageIndex, setCurrentImageIndex] = useState(0);
  const [privacyModalOpen, setPrivacyModalOpen] = useState(false);
  const [termsModalOpen, setTermsModalOpen] = useState(false);
  const [aboutModalOpen, setAboutModalOpen] = useState(false);

  useEffect(() => {
    AOS.init({ duration: 1000, once: true });
  }, []);

  const images = [
    '/images/healthycorn.png',
    '/images/prescriptions.png',
    '/images/detailedtables.png'
  ];

  const handlePrevImage = () => {
    setCurrentImageIndex((prev) => (prev === 0 ? images.length - 1 : prev - 1));
  };

  const handleNextImage = () => {
    setCurrentImageIndex((prev) => (prev === images.length - 1 ? 0 : prev + 1));
  };

  return (
    <>
      <div className="bg-(--color-white) scroll-smooth">
        <main>

          <div className="bg-[url(/images/background.png)] rounded-bl-[50px] rounded-br-[50px] rounded-tl-none rounded-tr-none relative h-197 bg-cover bg-center flex items-center justify-center">
            <nav className="fixed top-0 w-full container z-10 bg-transparent px-2 md:px-10 py-1 flex items-center justify-between">
              <div className="w-10 md:w-20 py-2 flex items-center">
                <img
                  src="/images/smalllogo.png"
                  alt="Logo"
                  className="h-14 w-14 md:h-18 md:w-18 object-cover"
                />
              </div>

              <div>
                <ul className="flex items-center font-bold space-x-4 md:space-x-15">
                  <li><button onClick={() => navigate('/getapp')} className="bg-(--color-lgreen) text-(--color-white) px-4 md:px-7 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-green) ease-in-out duration-250">Get App</button></li>
                  <li>
                    <button onClick={() => navigate('/header-menu')} className="cursor-pointer">
                      <img
                        src="/images/menu-green.png"
                        alt="Menu"
                        className="h-8 w-8 md:h-10 md:w-10 object-cover opacity-80 hover:opacity-100 duration-300"
                      />
                    </button>
                  </li>
                </ul>
              </div>
            </nav>

            {/* HERO PAGE */}
            <div className="relative flex flex-col items-center justify-center text-white text-center space-y-4 md:space-y-6 w-full px-4">
              <div
                data-aos="zoom-in" className="flex flex-col items-center">
                <img src="/images/mainlogo.png" alt="Maize Watch Logo" className=" w-80 md:w-100 lg:w-180 xl:w-250 m-auto rounded-full transition-all duration-300 hover:scale-105" />
              </div>

              <div
                data-aos="fade-up" data-aos-delay="200" className='lg:mt-10 '>
                <button onClick={() => {
                  const target = document.getElementById('about-section');
                  if (target) {
                    const offset = -250;
                    const bodyRect = document.body.getBoundingClientRect().top;
                    const elementRect = target.getBoundingClientRect().top;
                    const elementPosition = elementRect - bodyRect;
                    const offsetPosition = elementPosition + offset;

                    window.scrollTo({
                      top: offsetPosition,
                      behavior: 'smooth'
                    });
                  }
                }} className="animate-bounce mt-2 md:mt-4 px-6 hover:animate-none cursor-pointer md:px-8 py-3 md:py-3 border-2 border-(--color-white) text-(--color-white) rounded-full hover:scale-108 hover:bg-(--color-white) hover:text-(--color-dgreen) transition-all duration-300 text-base md:text-lg font-medium" >
                  See more ↓
                </button>
              </div>
            </div>
          </div>


          {/* ABOUT PART */}
          {/* <div data-aos="fade-up" data-aos-delay="200" className="relative rounded-full -mt-12 pb-8 md:pb-4 ">
            <div id="about-section" className="container rounded-full  mx-auto px-10 md:px-20 lg:px-18 xl:px-75">
              <div onClick={() => navigate('/product')} className="bg-[url(/images/container2.png)] bg-cover bg-center text-white rounded-31 p-6 md:p-23 pb-8 lg:pb-30 md:pb-25 hover:scale-99 transition-all ease-in-out duration-300 hover:text-maize-llgreen cursor-pointer">
                <div className="flex  flex-col md:flex-row items-start gap-4 md:gap-6 cursor-pointer">
                  <img src="/images/smiley.png" alt="" className="w-12 h-12 md:w-14 md:h-14" />
                  <div className='rounded-full'>
                    <h2 className="text-2xl  md:text-3xl font-bold mb-4 md:mb-6">
                      Maximize your yields,<br />minimize your worries.
                    </h2>
                    <p className="text-[14px] md:text-[16px] lg:text-[24px] xl:text-[18px] opacity-90 md:mr-10">
                      Maize Watch is a smart farming system that monitors real-time corn field
                      conditions using IoT sensors and delivers data-driven recommendations
                      through AI-powered prescriptive analytics—helping farmers grow
                      healthier crops, efficiently and sustainably.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div> */}

          {/* ABOUT PART */}
          <div 
            data-aos="fade-up" 
            data-aos-delay="200" 
            className="relative rounded-3xl -mt-12 pb-8 md:pb-4"
          >
            <div 
              id="about-section" 
              className="container rounded-3xl mx-auto px-10 md:px-20 lg:px-18 xl:px-75"
            >
              <div 
                onClick={() => navigate('/product')} 
                className="bg-[url(/images/container2.png)] bg-cover bg-center text-white rounded-3xl p-6 md:p-23 pb-8 lg:pb-30 md:pb-25 hover:scale-99 transition-all ease-in-out duration-300 hover:text-maize-llgreen cursor-pointer"
              >
                <div className="flex flex-col md:flex-row items-start gap-4 md:gap-6 cursor-pointer">
                  <img 
                    src="/images/smiley.png" 
                    alt="" 
                    className="w-12 h-12 md:w-14 md:h-14 rounded-full" 
                  />
                  <div className="rounded-3xl">
                    <h2 className="text-2xl md:text-3xl font-bold mb-4 md:mb-6">
                      Maximize your yields,<br />minimize your worries.
                    </h2>
                    <p className="text-[14px] md:text-[16px] lg:text-[24px] xl:text-[18px] opacity-90 md:mr-10">
                      Maize Watch is a smart farming system that monitors real-time corn field
                      conditions using IoT sensors and delivers data-driven recommendations
                      through AI-powered prescriptive analytics—helping farmers grow
                      healthier crops, efficiently and sustainably.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>


          <div className="py-12 md:py-12 px-4 md:px-30 ">
            <div className="container mx-auto">
              <div className="grid grid-cols-1 md:grid-cols-1 lg:grid-cols-3 gap-6 md:gap-8">

                {/* Mission Box */}
                <div className="mt-10 " data-aos="fade-up" data-aos-delay="300">
                  <div className="bg-(--color-dgreen)  bg-cover bg-center px-6 md:px-10 lg:px-12 pt-14 pb-10 rounded-[32px] text-white h-full transition-all duration-300 hover:opacity-90 hover:text-maize-dgreen overflow-visible">
                    <h3 className="text-3xl md:text-[40px] font-bold">Mission.</h3>
                    <div className="mt-6 md:mt-8">
                      <p className="text-sm md:text-base">
                        We aim to support Filipino corn farmers by providing real-time insights
                        for smarter, more efficient corn farming.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Principle Box */}
                <div className="mt-10" data-aos="fade-up" data-aos-delay="600">
                  <div className="bg-(--color-dgreen) bg-cover bg-center px-6 md:px-10 lg:px-12 pt-14 pb-10 rounded-[32px] text-white h-full transition-all duration-300 hover:opacity-90 hover:text-maize-dgreen overflow-visible">
                    <h3 className="text-3xl md:text-[40px] font-bold">Principle.</h3>
                    <div className="mt-6 md:mt-8">
                      <p className="text-sm md:text-base">
                        We use IoT and Data Analytics to simplify decision-making, promote sustainable
                        practices, and ensure accessible tools for all.
                      </p>
                    </div>
                  </div>
                </div>

                {/* Values Box */}
                <div className="mt-10" data-aos="fade-up" data-aos-delay="900">
                  <div className="bg-(--color-dgreen) bg-cover bg-center px-6 md:px-10 lg:px-12 pt-14 pb-10 rounded-[32px] text-white h-full transition-all duration-300 hover:opacity-90 hover:text-maize-dgreen overflow-visible">
                    <h3 className="text-3xl md:text-[40px] font-bold">Values.</h3>
                    <div className="mt-6 md:mt-8 mb-3">
                      <p className="text-sm md:text-base">
                        We value innovation, sustainability, and empowering farmers through accurate,
                        data-driven solutions.
                      </p>
                    </div>
                  </div>
                </div>

              </div>
            </div>
          </div>



          <hr className="my-4 border-t border-maize-lgreen mt-10  mx-10 xl:mx-40" />

          {/* APP PART */}
          <div className="py-16 px-4 md:px-20">
            <div className="container mx-auto">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">

                <div className=" ml-18  space-y-6">
                  <div className="flex items-center gap-3">
                    <div data-aos="fade-down" data-aos-delay="400" className="p-2 ">
                      <img src="/images/header.png" alt="Brain Icon" className="w-full h-full" />
                    </div>
                  </div>

                  <p data-aos="fade-right" data-aos-delay="400" className="text-gray-700 text-sm md:text-base xl:text-lg max-w-xl">
                    ──────── &nbsp;&nbsp;&nbsp; We also offer a real-time app that helps corn farmers optimize crop yield through IoT sensor data. It monitors key environmental factors and provides actionable insights from our prescriptive analytics, enabling smarter farming decisions for better productivity and sustainability.
                  </p>

                  <div data-aos="fade" data-aos-delay="500" 
                    className="flex items-center gap-5 md:gap-70 lg:gap-20 xl:gap-90 relative z-20"
                  >
                    <button 
                      onClick={() => navigate('/solutions')} 
                      className="flex items-center gap-2 whitespace-nowrap text-lg font-semibold text-maize-dgreen border-b-2 border-maize-dgreen hover:border-maize-lgreen hover:text-(--color-lgreen) transition-all ease-in-out duration-300 pb-1"
                    >
                      LEARN MORE
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 flex-shrink-0" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                      </svg>
                    </button>

                    <div className="flex gap-4 z-20 relative">
                      <button
                        onClick={handlePrevImage}
                        className="cursor-pointer w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-lgreen) hover:text-(--color-white) transition-all duration-300 z-20"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
                        </svg>
                      </button>
                      <button
                        onClick={handleNextImage}
                        className="cursor-pointer w-12 h-12 rounded-full border-2 border-(--color-dgreen) flex items-center justify-center hover:bg-(--color-lgreen) hover:text-(--color-white) transition-all duration-300 z-20"
                      >
                        <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6 text-(--color-dgreen)" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
                        </svg>
                      </button>
                    </div>
                  </div>




                </div>

                <div data-aos="fade-left" data-aos-delay="400" className="relative flex justify-center items-center">
                  <div className="bg-maize-lgreen w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-15 transition-discrete ease-in-out duration-500"></div>
                  <img
                    src={images[currentImageIndex]}
                    alt="Maize Watch App Preview"
                    className="relative w-[280px] md:w-[400px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                  />
                </div>
              </div>
            </div>
          </div>

          <br /><br />

          {/* TECHNOLOGY PART */}
          <div className="bg-[url(/images/background2.png)] rounded-tr-[50px] rounded-tl-[50px] rounded-bl-none relative min-h-screen bg-cover bg-center flex items-center justify-center py-8 md:py-20">
            <div className="container px-4 md:px-16">
              <div className="grid grid-cols-1 lg:grid-cols-2 gap-10 md:gap-4 lg:gap-0">

                {/* colum1 */}
                <div data-aos="fade" className="text-white space-y-4 md:space-y-6 mt-4 md:mt-30 lg:mt-40 2xl:mt-100 px-2 md:px-0">
                  <h2 data-aos="fade-down" data-aos-delay="400" className="text-2xl md:text-4xl lg:text-5xl font-bold leading-tight">
                    The Technology<br />Behind.
                  </h2>
                  <div data-aos-delay="500">

                    <button onClick={() => navigate('/technology')} className="flex items-center gap-2 text-sm md:text-lg font-semibold text-(--color-white) border-b-2 border-(--color-white) pb-1 hover:text-(--color-lgreen) hover:border-(--color-lgreen) transition-all duration-300 cursor-pointer">
                      LEARN MORE
                      <svg xmlns="http://www.w3.org/2000/svg" className="h-4 w-4 md:h-5 md:w-5" viewBox="0 0 20 20" fill="currentColor">
                        <path fillRule="evenodd" d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z" clipRule="evenodd" />
                      </svg>
                    </button>

                  </div>
                </div>

                {/* colum2 */}
                {/* subcolumn1 */}
                <div data-aos="fade-left" data-aos-delay="400" className="container mx-auto xl:col-span-2 2xl:col-span-1 px-4 xl:mx-0">
                  <div className="grid grid-cols-1 xl:grid-cols-2 ">

                    <div className="text-white mt-4 md:mt-40 mx-auto w-full max-w-[320px] lg:max-w-full">
                      <div className="bg-(--color-dgreen) 2xl:h-100 rounded-tl-[30px] rounded-tr-[30px] rounded-bl-[30px] rounded-br-[30px] xl:rounded-tr-none xl:rounded-br-none p-6 md:p-15 lg:p-20 xl:p-20 2xl:p-17">
                        <h3 className="text-md md:text-2xl lg:text-3xl 2xl:text-[28px] font-bold uppercase mb-3 md:mb-4 2xl:mb-7">
                          Real-time<br />Monitoring
                        </h3>
                        <p className="leading-relaxed text-sm md:text-base lg:text-[18px] 2xl:text-[16px] text-white/90">
                          Monitor your corn crops in real time with IoT sensors—track temperature, soil moisture, humidity, pH level, and light intensity for healthier harvests.
                        </p>
                      </div>
                    </div>

                    {/* subcolumn2 */}
                    <div className="text-white mt-4 md:mt-10 xl:mt-40 mx-auto w-full max-w-[320px] lg:max-w-full">
                      <div className="bg-(--color-lgreen)  2xl:h-100 rounded-tl-[30px] rounded-tr-[30px] rounded-bl-[30px] rounded-br-[30px] xl:rounded-tl-none xl:rounded-bl-none p-6 md:p-15 lg:p-20 xl:p-20 2xl:p-17">
                        <h3 className="text-md md:text-2xl lg:text-3xl 2xl:text-[28px] font-bold uppercase mb-3 md:mb-4 2xl:mb-6">
                          Prescriptive<br />Insights
                        </h3>
                        <p className="leading-relaxed text-sm md:text-base lg:text-[18px] 2xl:text-[16px] text-white/90">
                          We turn real-time corn crop data into smart recommendations—reducing risks, solve issues fast, and maximize your farm's potential.
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <br />


          {/* FOOTER PART */}
          <footer data-aos="fade-up" data-aos-delay="200" className="bg-(--color-white) py-6 px-4 md:px-10">
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
                    <li><button
                      onClick={() => {
                        setPrivacyModalOpen(true);
                      }}
                      className="hover:opacity-80 transition-all duration-300">Privacy</button></li>
                    <li><button
                      onClick={() => {
                        setTermsModalOpen(true);
                      }} className="hover:opacity-80 transition-all duration-300">Terms of Use</button></li>
                    <li><button
                      onClick={() => {
                        setAboutModalOpen(true);
                      }} className="hover:opacity-80 transition-all duration-300">About us</button></li>
                  </ul>
                </div>

                <div className="mt-2 md:mt-0">
                  <h4 className="font-semibold text-base md:text-lg mb-3 text-(--color-dgreen)">Contact Us</h4>
                  <ul className="space-y-2 text-sm md:text-base text-(--color-dgreen)">
                    <li>2129 Taft Avenue</li>
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
      </div>

      {aboutModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button
              onClick={() => setAboutModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25} className='text-white cursor-pointer hover:text-maize-llgreen ease-in-out duration-250' />
            </button>

            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img
                  src="/maizewatchlogo.png"
                  alt="Maize Watch Icon"
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>

            <div className="text-sm text-white mb-6 mx-8">
              <p>
                Maize Watch empowers corn farmers to achieve higher yields and greater
                profitability through data-driven insights. Comprehensive data visualizations
                provide clarity on performance across all key health and environmental conditions,
                enabling timely interventions and optimized resource allocation. Integrated
                account management tools allow farmers to track and analyze sensor data,
                identify areas for improvement, and implement best practices. The result is
                increased agricultural efficiency, reduced costs, and improved overall farm
                productivity.
              </p>
            </div>

          </div>
        </div>
      )}

      {privacyModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button
              onClick={() => setPrivacyModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25} className='text-white cursor-pointer hover:text-maize-llgreen ease-in-out duration-250' />
            </button>

            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img
                  src="/maizewatchlogo.png"
                  alt="Maize Watch Icon"
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>

            <div className="space-y-6 text-sm text-white max-h-[70vh] overflow-y-auto px-4">
              <h2 className="text-xl font-bold text-left mb-4">Privacy Information</h2>

              <p>
                At Maize Watch, we are committed to protecting the privacy of our users, particularly corn farmers who entrust us with their valuable agricultural data. This Privacy Information outlines how we collect, use, and protect your information when you use our platform.
              </p>

              <div>
                <h3 className="font-semibold text-base mb-1">1. Information We Collect:</h3>
                <p className="mb-2">To provide you with data-driven insights and optimize your corn yields, Maize Watch collects the following types of information:</p>

                <ul className="list-disc pl-6 space-y-1">
                  <li>
                    <strong>Farm-Specific Data:</strong> Location (GPS coordinates of fields), field size and boundaries, crop variety, planting/harvesting dates, and yield data.
                  </li>
                  <li>
                    <strong>Sensor Data:</strong> Soil moisture/nutrient levels, temperature (soil/ambient), humidity, light intensity, and other relevant environmental data.
                  </li>
                  <li>
                    <strong>Account Information:</strong> Your name, contact info, farm name/ID, and login credentials (encrypted).
                  </li>
                  <li>
                    <strong>Usage Data:</strong> Features accessed, time spent, reports generated, and anonymized device info.
                  </li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">2. How We Use Your Information:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li><strong>To Provide Core Services:</strong> Visualize farm performance, analyze conditions, offer recommendations, and track progress.</li>
                  <li><strong>To Improve Maize Watch:</strong> Enhance features, develop new tools, and improve models (often using anonymized data).</li>
                  <li><strong>For Communication:</strong> Send updates, alerts, and respond to inquiries.</li>
                  <li><strong>For Security:</strong> Ensure platform integrity, prevent fraud, and comply with legal duties.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">3. Data Sharing and Disclosure:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li><strong>With Your Consent:</strong> Data is shared only with parties you approve (e.g., consultants).</li>
                  <li><strong>Service Providers:</strong> Only trusted providers under strict agreements.</li>
                  <li><strong>Aggregated/Anonymized Data:</strong> Used for research or benchmarking without revealing identities.</li>
                  <li><strong>Legal Requirements:</strong> Disclosed only when legally necessary.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">4. Data Security:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Encryption (in transit & at rest)</li>
                  <li>Strict access controls</li>
                  <li>Regular security audits</li>
                  <li>Secure data backups</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">5. Your Choices and Rights:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Access, update, or correct your data anytime</li>
                  <li>Request a copy of your data (data portability)</li>
                  <li>Request data deletion (subject to legal retention)</li>
                  <li>Opt-out of non-essential communications</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">6. Data Retention:</h3>
                <p>
                  Your data is retained while your account is active and for a reasonable period afterward to comply with obligations and ensure continuity.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">7. Changes to This Privacy Information:</h3>
                <p>
                  Updates to this Privacy Information will be posted on our website or communicated appropriately. Please review it periodically.
                </p>
              </div>

            </div>


          </div>
        </div>
      )}

      {termsModalOpen && (
        <div data-aos="fade" className="fixed inset-0 bg-black bg-opacity-90 backdrop-blur-sm flex items-center justify-center z-50">
          <div data-aos="fade-up" data-aos-delay="100" className="bg-(--color-dgreen) rounded-lg w-full max-w-lg mx-4 p-6 relative">
            <button
              onClick={() => setTermsModalOpen(false)}
              className="absolute top-4 right-4 text-gray-500 hover:text-gray-700"
            >
              <X size={25} className='text-(--color-white) cursor-pointer hover:text-(--color-llgreen) ease-in-out duration-250' />
            </button>

            <div className="flex items-center gap-2 mb-4">
              <div className="rounded-full">
                <img
                  src="/maizewatchlogo.png"
                  alt="Maize Watch Icon"
                  className="h-10 w-10"
                  onError={(e) => {
                    e.currentTarget.src = "https://via.placeholder.com/24";
                  }}
                />
              </div>
              <span className="text-[#61983f] text-lg font-bold uppercase tracking-wider">Maize Watch</span>
            </div>

            <div className="space-y-6 text-sm text-white max-h-[70vh] overflow-y-auto px-4">
              <h2 className="text-xl font-bold text-left mb-4">Terms of Use</h2>

              <p>
                Welcome to Maize Watch. By accessing or using our platform, services, and related tools, you agree to comply with and be bound by these Terms of Use. If you do not agree with any part of these terms, please do not use Maize Watch.
              </p>

              <div>
                <h3 className="font-semibold text-base mb-1">1. Use of the Platform:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>You may only use Maize Watch for lawful purposes and in accordance with these terms.</li>
                  <li>You are responsible for maintaining the confidentiality of your account credentials and all activities under your account.</li>
                  <li>You agree not to misuse the platform, interfere with its security or functionality, or attempt unauthorized access to any part of the system.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">2. Data Ownership and Usage:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>You retain full ownership of your farm data and sensor information.</li>
                  <li>By using Maize Watch, you grant us permission to analyze your data to provide personalized insights and improve platform performance.</li>
                  <li>We will not share your identifiable data without your explicit consent, as outlined in our Privacy Policy.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">3. Intellectual Property:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>All content on Maize Watch, including visualizations, software, text, graphics, and logos, is the property of Maize Watch or its licensors.</li>
                  <li>You may not reproduce, distribute, modify, or create derivative works without our written permission.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">4. Account Termination:</h3>
                <p>
                  We reserve the right to suspend or terminate your access to Maize Watch at any time if you violate these terms, abuse the platform, or engage in any behavior that disrupts service for other users.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">5. Disclaimers:</h3>
                <ul className="list-disc pl-6 space-y-1">
                  <li>Maize Watch provides data-based insights to support agricultural decisions. Final decisions regarding farming practices remain your responsibility.</li>
                  <li>We do not guarantee specific yield outcomes or profitability as agricultural success depends on many uncontrollable factors.</li>
                  <li>The platform is provided “as-is” and “as available” without warranties of any kind.</li>
                </ul>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">6. Limitation of Liability:</h3>
                <p>
                  To the extent permitted by law, Maize Watch shall not be liable for any indirect, incidental, or consequential damages arising from your use of the platform, including data loss, yield loss, or farm-related decisions made based on our analytics.
                </p>
              </div>

              <div>
                <h3 className="font-semibold text-base mb-1">7. Updates to the Terms:</h3>
                <p>
                  We may update these Terms of Use from time to time. Material changes will be communicated through our platform or via email. Continued use of Maize Watch means you accept the updated terms.
                </p>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  )
}