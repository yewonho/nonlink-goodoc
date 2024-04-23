'use client'
import { useState, useEffect } from "react";

export default function OptionNav({onSelect}){
    
    const [addFocus, setAddFocus] = useState("기본설정");

    useEffect(() => {
        
    })


    return(
        <div className="OptionNav">
        <span onClick={() => {onSelect("기본설정");}}>기본설정</span>
        <span className="OptionNavFocus" onClick={() => {onSelect("항목설정");}}>항목설정</span>
        <span onClick={() => {onSelect("테스트");}}>테스트</span>
      </div>
    )
}