import { useNavigate } from 'react-router-dom';
import { FaAndroid, FaApple } from 'react-icons/fa';

export default function GetAppPage() {
    const navigate = useNavigate();

  return (
    <>
      <body className="pt-30 lg:pt-0 lg:px-10 xl:px-20 bg-(--color-white) lg:h-screen lg:overflow-hidden">
        <main className="lg:h-full">
        <div className="rounded-bl-[50px] rounded-br-[50px] rounded-tl-none rounded-tr-none relative h-197 bg-cover bg-center flex items-center justify-center">

        <nav className="fixed top-0 w-full container z-10 bg-transparent px-2 md:px-10 py-1 flex items-center justify-between">
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
                  <li>
                    <button>
                    <img
                    onClick={() => navigate('/headermenu')}
                    src="/images/menu-green.png"
                    alt="Logo"
                    className="h-8 w-8 md:h-10 md:w-10 object-cover opacity-80 hover:opacity-100 duration-300"
                    />
                    </button>
                  </li>
                </ul>
              </div>
            </nav>

        <div className=" pt-20 pb-10 px-4 md:px-10">
              <div className="container mx-auto">
                <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                    <div className="relative flex justify-center items-center">
                        
                        <div className="bg-transparent
                         w-[300px] h-[300px] md:w-[400px] md:h-[400px] rounded-full absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-15 transition-discrete ease-in-out duration-500"></div>
                            <img
                            src="/images/getapp.png"
                            alt="Maize Watch App Preview"
                            className="relative w-[340px] md:w-[460px] mx-auto fade-out-left transition-discrete ease-in-out duration-500"
                            />
                        </div>

                  <div className=" ml-2 space-y-6">
                    
                    <p className=" text-(--color-dgreen) text-2xl md:text-4xl lg:text-5xl font-extrabold leading-tight">
                        Download the app now!
                    </p>
                    <p className=" text-(--color-dgreen) text-1xl md:text-2xl font-regular italic leading-tight">
                        Maximize your yields, minimize your worries.
                    </p> <br/>
                        <div className="mx-auto flex">
                        <button onClick={() => navigate('/getapp')} className="bg-(--color-green) text-(--color-white) px-4 md:px-7 w-40 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-dgreen) mx-5 ease-in-out duration-250 flex items-center justify-center gap-2">
                            <FaAndroid className="text-xl" />
                            Android
                        </button> 
                        <button onClick={() => navigate('/getapp')} className="bg-(--color-green) text-(--color-white) px-4 md:px-7 w-40 py-2 md:py-3 rounded-md text-base md:text-lg font-semibold cursor-pointer hover:bg-(--color-dgreen) mx-5 ease-in-out duration-250 flex items-center justify-center gap-2">
                            <FaApple className="text-xl" />
                            iOS
                        </button>
                        </div>

                        <div className="mt-8 space-y-4">
                            <div className="bg-(--color-lightgreen) bg-opacity-10 p-6 rounded-lg">
                                <h3 className="text-(--color-dgreen) text-xl font-bold mb-4">App Specifications</h3>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div className="space-y-2">
                                        <p className="text-(--color-dgreen) font-semibold">File Size:</p>
                                        <p className="text-(--color-dgreen)">• Android: 25MB</p>
                                        <p className="text-(--color-dgreen)">• iOS: 30MB</p>
                                    </div>
                                    <div className="space-y-2">
                                        <p className="text-(--color-dgreen) font-semibold">Languages:</p>
                                        <p className="text-(--color-dgreen)">• Filipino (Tagalog)</p>
                                        <p className="text-(--color-dgreen)">• English</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                  </div>
                  
                  
                </div>
              </div>
            </div>
    
            </div>
        </main>
      </body>
    </>
  )
}