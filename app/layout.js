'use client'

import { Inter } from "next/font/google";
import "./globals.css";
import Navlayout from "./NavLayout";
//import { GlobalStateProvider, setGlobalDispatch } from '../lib/GlobalState';



const inter = Inter({ subsets: ["latin"] });


export default function RootLayout({ children }) {
 return (
    <html lang="en">
     
      <body className={inter.className}>

          {children}

      </body>
      
    </html>
  );
}