'use client'

export default function OptionBottom(){
   
   
   
   
    const cancleClick = ()=>{
        window.location.href = '/';
    }

   
    return(
        <div className="optionBottom">
            <button className="optionBottom_btn1" type="submit" onClick={cancleClick}>저장</button>
            <button className="optionBottom_btn2" type="button" onClick={cancleClick}>취소</button>
        </div>
    )
}