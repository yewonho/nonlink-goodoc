import Image from "next/image";
import Checkbox from "./checkbox";
import Loginbtn from "./loginbtn"

export default function login(){

    console.log("로그인페이지");
    return(
        <div>
            <div className="mainName">
                <img src="/GDR/Login_ci_new2.png" alt="main Image"/>
            </div>
            <form>
                <div className="input-Idcontainer">
                    <input type="text" placeholder="아이디 입력"/>
                </div>
                <div className="input-Pwcontainer">
                    <input type="password" placeholder="비밀번호"/>
                </div>

                <Checkbox/>

                {/* <div className="input-Loginbutton">
                    <button type="submit">
                        <img src="/GDR/login_button_normal_new.png" alt="Button Image"/>
                    </button>
                </div> */}

                <Loginbtn/>

            </form>
                <img src="/GDR/div_login.png" alt="main Image"/>
            <div className="login-Foot">
                <img src="/GDR/btn_chatting.png" alt="main Image"/> <img src="/GDR/btn_remotesupport.png" alt="main Image"/>
            </div>
        </div>
    );
}