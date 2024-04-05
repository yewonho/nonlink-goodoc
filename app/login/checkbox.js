'use client'

import { useEffect, useState } from "react"

export default function Checkbox(){

    const [isChecked1, setIsChecked1] = useState(false);
    const [isChecked2, setIsChecked2] = useState(false);

    const handleCheckboxChange1 = () => {
        setIsChecked1(!isChecked1);
        console.log("Checkbox 1 is checked:", !isChecked1);
    };

    const handleCheckboxChange2 = () => {
        setIsChecked2(!isChecked2);
        console.log("Checkbox 2 is checked:", !isChecked2);
    };

    useEffect(() => {
        // isChecked 상태가 변경될 때마다 이미지를 갱신합니다.
        // 체크박스가 체크되면 isChecked가 true이므로 이미지를 변경합니다.
        const img1 = document.getElementById("checkbox-img1");
        const img2 = document.getElementById("checkbox-img2");
        
        if (isChecked1) {
            img1.src = "/GDR/cb_login_on.png";
            img1.alt = "checked";
            console.log("체크상태1");
        } else {
            img1.src = "/GDR/cb_login_off.png";
            img1.alt = "unchecked";
            console.log("안체크상태1");
        }

        if (isChecked2) {
            img2.src = "/GDR/cb_login_on.png";
            img2.alt = "checked";
            console.log("체크상태2");
        } else {
            img2.src = "/GDR/cb_login_off.png";
            img2.alt = "unchecked";
            console.log("안체크상태2");
        }
    }, [isChecked1, isChecked2]);

    return (
        <div>
            <div className="input-Ckcontainer">
                <input
                    type="checkbox"
                    checked={isChecked1}
                    onChange={handleCheckboxChange1}
                    id="checkbox1"
                />
                <label htmlFor="checkbox1">
                    <img id="checkbox-img1" src="/GDR/cb_login_off.png" alt="unchecked" draggable={false}/>
                     <span>자동로그인</span>
                </label>

                <input
                    type="checkbox"
                    checked={isChecked2}
                    onChange={handleCheckboxChange2}
                    id="checkbox2"
                />
                <label htmlFor="checkbox2">
                    <img id="checkbox-img2" src="/GDR/cb_login_off.png" alt="unchecked" draggable={false}/>
                    <span>Windows와 함께 프로그램 시작</span>
                </label>
            </div>
        </div>
    );
}
