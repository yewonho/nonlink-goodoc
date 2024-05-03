import Image from "next/image";
import styles from "./page.module.css";
import Link from "next/link";
import Reception from "./receptions/reception";
import RnrUnit from "./receptions/rnrUnit";
import Timer from "./receptions/timer";
import Refresh from "./receptions/refresh";

export default function Home() {
  return (
    <main>
      <div className="TimeandRefresh"><Timer/><Refresh/></div> 
      <div>
       <div className="receptionLabel">접수 (0명) </div>
            <div className="receptionCheck">
                <input type="checkbox"/><span>전체</span>
                <input type="checkbox"/><span>접수</span>
                <input type="checkbox"/><span>내원</span>
                <input type="checkbox"/><span>완료</span>
                <input type="checkbox"/><span>취소</span>
                <img src="/GDR/filter_normal.png"/>
            </div>
        <Reception/> 
        <div className="receptionLabel">접수 요청 (0명) </div>
            <div className="receptionCheck">
                <input type="checkbox"/><span>전체</span>
                <input type="checkbox"/><span>접수</span>
                <input type="checkbox"/><span>취소</span>
                <img src="/GDR/filter_normal.png"/>
            </div>
        <RnrUnit/>
      </div>
      

  </main>
  );
}



//      <Link href="/">home</Link>
//<Link href="/login">login페이지</Link>