'use client'
import { useState, useEffect } from "react";

export default function OptionNav({onSelect}){
    
    const [addFocus, setAddFocus] = useState("기본설정");
    const [selectedOption, setSelectedOption] = useState(null);


    // const toggleClass = (event) => {
    //   const id = event.target.id;
    //   console.log(id)

    //  switch (id){
    //   case '기본' :
    //     document.getElementById(id).className('OptionNavFocus')


    //  }

    // }
    const handleClick = (option) => {
      setSelectedOption(option);
      onSelect(option);
    };



    //OptionNavFocus

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

// return(
//   <div className="OptionNav">
//   <span className={selectedOption === "기본설정" ? "OptionNavFocus" : ""} 
//   onClick={(e) => {onSelect("기본설정"); toggleClass(e);}}>기본설정</span>
//   <span className={selectedOption === "항목설정" ? "OptionNavFocus" : ""}
//   onClick={(e) => {onSelect("항목설정"); toggleClass(e);} }>항목설정</span>
//   <span className={selectedOption === "테스트" ? "OptionNavFocus" : ""} 
//   onClick={(e) => {onSelect("테스트"); toggleClass(e);}}>테스트</span>
// </div>
// )