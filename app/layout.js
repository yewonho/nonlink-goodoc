import { Inter } from "next/font/google";
import "./globals.css";
import Navlayout from "./NavLayout";


const inter = Inter({ subsets: ["latin"] });

export const metadata = {
  title: "비연동 굿닥",
  description: "굿닥 비연동",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
      <div className="bodyMain">
        <Navlayout/>
        {children}
      </div>
      </body>
    </html>
  );
}
