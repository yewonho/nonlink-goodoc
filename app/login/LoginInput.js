"use client"
import { useState , useEffect } from "react"

export default function LoginInput() {
    
    const [eyeBtn, setEyebtn] = useState('closed');
    const [inputId, setInputId] = useState('FocusOff');
    const [inputPw, setInputpw] = useState('FocusOff');



    //눈 아이콘 on / off 
    const eyeHandle = () =>{
        setEyebtn(eyeBtn === 'closed' ? 'open' : 'closed');
    }

    //아이디 input 포커스 온
    const inputIdfocuson = () =>{
        setInputId('FocusOn'); 
    }

    //아이디 input 포커스 아웃
    const inputIdfocusoff = () =>{
        setInputId('FocusOff');
    }


    //비번 input 포커스 온
    const inputPwfocuson = () =>{
        setInputpw('FocusOn'); 
    }

    //비번 input 포커스 아웃
    const inputPwfusoff = () =>{
        setInputpw('FocusOff');
    }




    useEffect(()=>{
        const idBack = document.querySelector('.input-Idcontainer');
        const pwBack = document.querySelector('.input-Pwcontainer');
        const idInput = document.querySelector('.input-IdcontainerInput');
        const pwInput = document.querySelector('.input-PwcontainerInput');



        if(inputId == 'FocusOn'){
            idBack.style.backgroundImage = 'url(/GDR/bg_login_id_1.png)';
            idInput.style.backgroundColor ='rgb(250,250,252)';
            console.log('이펙트포커스온'  + inputId)
        } else if(inputId == 'FocusOff'){
            idBack.style.backgroundImage = 'url(/GDR/bg_login_id_0.png)';
            idInput.style.backgroundColor ='rgb(255,255,255)';
            console.log('이펙트포커스오프'  + inputId)
        }



        if(inputPw == 'FocusOn'){
            pwBack.style.backgroundImage = 'url(/GDR/bg_login_pw_1.png)';
            pwInput.style.backgroundColor ='rgb(250,250,252)';
            console.log('이펙트포커스온'  + inputPw)
        } else if(inputPw == 'FocusOff'){
            pwBack.style.backgroundImage = 'url(/GDR/bg_login_pw_0.png)';
            pwInput.style.backgroundColor ='rgb(255,255,255)';
            console.log('이펙트포커스오프'  + inputPw)
        }

    })


    return(
        <div>
            <div className="input-Idcontainer">
                <input className="input-IdcontainerInput" type="text" placeholder="아이디 입력" onFocus={inputIdfocuson} onBlur={inputIdfocusoff}/>
            </div>

            <div>
                {eyeBtn === 'closed' ? (
                    <div className="input-Pwcontainer">
                        <input className="input-PwcontainerInput" type="password" placeholder="비밀번호" onFocus={inputPwfocuson} onBlur={inputPwfusoff}/>
                        <img className="input-PwcontainerImg" src="/GDR/ic_login_eye_closed.png" alt="eye_closed" onClick={eyeHandle}/>
                    </div>
                    ) : (
                    <div className="input-Pwcontainer">
                        <input className="input-PwcontainerInput" type="text" placeholder="비밀번호" onFocus={inputPwfocuson} onBlur={inputPwfusoff}/>
                        <img className="input-PwcontainerImg" src="/GDR/ic_login_eye.png" alt="eye_open" onClick={eyeHandle}/>
                    </div>
                )}
            </div>

        </div>
    )
}
