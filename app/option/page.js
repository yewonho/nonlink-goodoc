'use client'

import React, { useState } from "react";
import OptionBottom from "./optionBottom";
import OptionNav from "./optionNav";
import OptionSet from "./optionSet";
import OptionCheck from "./optionCheck";
import OptionTest from "./optionTest";


export default function option(){
    const [selectedOption, setSelectedOption] = useState("기본설정");

    const handleOptionSelect = (option) => {
      setSelectedOption(option);
      console.log(option);
      console.log("클릭했다");
      
    };
  
    return (
      <>
        <OptionNav onSelect={handleOptionSelect} />
        {selectedOption === "기본설정" && <OptionSet />}
        {selectedOption === "항목설정" && <OptionCheck/>}
        {selectedOption === "테스트" && <OptionTest />}
        <OptionBottom />
      </>
    );
  }