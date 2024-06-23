import Image from "next/image";
import Checkbox from "./checkbox";
import Loginbtn from "./loginbtn"
import LoginInput from "./LoginInput";
import LINK from "next/link";
import DllCall from "./dllCall";
import Callinit from "./callinit";

export default function login(){

    return(
        <div>
            <div className="mainName">
                <img src="/GDR/Login_ci_new2.png" alt="main Image" draggable={false}/>
            </div>
            
            <form>
                <LoginInput/>
                <Checkbox/>
                <span>여기는 에러메시지</span>
                <Loginbtn/>
            </form>
            
            <div className="login-Foot" >
                <LINK href="https://www.naver.com/" target="_blank" draggable={false}>
                    <img className="footChat" src="/GDR/btn_chatting.png" alt="main Image" draggable={false}/> 
                </LINK>
                <LINK href="https://www.naver.com/" target="_blank" draggable={false}>
                    <img className="footSupport" src="/GDR/btn_remotesupport.png" alt="main Image" draggable={false}/>
                </LINK>
            </div>
            <DllCall/>
            <Callinit/>
        </div>
    );
    
}

