'use client'
import { useState } from "react";
import OptionDropdown from "./optionDropdown";



export default function OptionSet(){
   

    const [isOpen, setIsOpen] = useState(false);
    const [options] = useState(['Option 1', 'Option 2', 'Option 3']);

    const toggleDropDown = () => {
    setIsOpen(!isOpen);
     };
   
    return(
        <>
        <form>
        <div className="frontOption">
            <div>실행위치</div>
            <div>다른 창을 열어도 프로그램이 맨 앞에 위치하도록 유지할 수 있습니다.</div>
            <input type="checkbox" style={{marginTop : '10px' }}/>
            <span>항상 맨 앞에 유지하기</span>
        </div>

        <div className="frontOption">
            <div>병원정보</div>
            <div>
                <span style={{marginRight : '10px' }}>요양기관 번호</span>
                <input type="text"/>
            </div>
            <div>
                <span style={{marginRight : '58px' }}>차트 ID</span>
                <input type="text"/>
            </div>
        </div>
        <div className="frontOption_Set">
            <div>차트 설정</div>
            <div>환자 접수 정보를 전송할 프로그램을 설정합니다.</div>
            <div>
                <input type="checkbox" style={{marginBottom : '10px' }}/>
                <span>환자조회</span>
                <OptionDropdown/>
            </div>
            <textarea/>
            
        </div>

        </form>
        </>
    )
}