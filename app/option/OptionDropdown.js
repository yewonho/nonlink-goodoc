import React from "react";
import Select from "react-select";


export default function OptionDropdown(){
    
    const options = [
        {value: 0 , label: "없음"},
        {value: 1 , label: "의사랑"},
        {value: 2 , label: "아이프로(덴탑)"},
        {value: 3 , label: "덴트웹"},
        {value: 4 , label: "하나로"}
    ]

    const customStyles = {
            control: (provided, state) => ({
            ...provided,
            height: '30px',
            width: '300px',
            fontSize:'15px' // 높이를 원하는 값으로 조정합니다.
            // 다른 스타일 속성들도 여기에 추가할 수 있습니다.
            }),
            menu: (provided, state) => ({
                ...provided,
                height: '200px',
                width: '300px' // 원하는 높이로 수정
                // 다른 스타일 속성들도 필요한 경우 여기에 추가
              }),
              menuList: (provided, state) => ({
                ...provided,
                height: '200px',
                width: '300px' // 원하는 높이로 수정
                // 다른 스타일 속성들도 필요한 경우 여기에 추가
              }),
      };

      const defaultValue = options[0];

    
    return(
        <div >
            <Select options ={options} styles={customStyles} defaultValue={defaultValue}/>
        </div>
    )
}
