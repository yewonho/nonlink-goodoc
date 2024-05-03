'use client'
import { useState} from "react";

export default function OptionNav({onSelect}){
    
    const [selectedOption, setSelectedOption] = useState("기본설정");


    const handleClick = (option) => {
      setSelectedOption(option);
      onSelect(option);
    };



    return(
        <div className="OptionNav">
        <span className={selectedOption === "기본설정" ? "OptionNavFocus" : ""} 
        onClick={() => handleClick("기본설정")}>기본설정</span>
        <span className={selectedOption === "항목설정" ? "OptionNavFocus" : ""}
        onClick={() => handleClick("항목설정") }>항목설정</span>
        <span className={selectedOption === "테스트" ? "OptionNavFocus" : ""} 
        onClick={() => handleClick("테스트")}>테스트</span>
      </div>
    )
}
