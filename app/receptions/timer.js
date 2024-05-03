'use client'

import { useEffect, useState } from "react"

export default function Timer(){

    const [formattedTime, setFormattedTime] = useState('');


    useEffect(()=>{
        const intervalId = setInterval(() => {
            const now = new Date();
            const year = now.getFullYear();
            const month = String(now.getMonth() + 1).padStart(2, '0');
            const day = String(now.getDate()).padStart(2, '0');
            const hours = String(now.getHours()).padStart(2, '0');
            const minutes = String(now.getMinutes()).padStart(2, '0');
            const seconds = String(now.getSeconds()).padStart(2, '0');
            const daysOfWeek = ['일', '월', '화', '수', '목', '금', '토'];
            const dayOfWeek = daysOfWeek[now.getDay()];
      
            const formattedTimeString = `${year}년 ${month}월 ${day}일 (${dayOfWeek}) ${hours}:${minutes}:${seconds}`;
            setFormattedTime(formattedTimeString);
          }, 1000); // 매 초마다 업데이트


            return () => clearInterval(intervalId); 
        }, []);

    
    return(
      <span> {formattedTime} </span>
    );
}