import Image from "next/image";
import styles from "./page.module.css";
import Link from "next/link";

export default function Home() {
  return (
    <main>
    <div className="navbar">
      <Link href="/">home</Link>
      <Link href="/login">login페이지</Link>
    </div>
    <h1 className="title">Programming Log</h1>
    <p className="title-sub">by dev kim</p>
  </main>
  );
}
