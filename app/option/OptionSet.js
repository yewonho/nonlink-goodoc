'use client'

export default function OptionSet(){
    return(
        <>
        <form>
        <div className="frontOption">
            <div>실행위치</div>
            <div>다른 창을 열어도 프로그램이 맨 앞에 위치하도록 유지할 수 있습니다.</div>
            <input type="checkbox"/>
            <span>항상 맨 앞에 유지하기</span>
        </div>

        <div className="frontOption">
            <div>병원정보</div>
            <div>
                <span>요양기관 번호</span>
                <input type="text"/>
            </div>
            <div>
                <span>차트 ID</span>
                <input type="text"/>
            </div>
        </div>
        <div className="frontOption">
            <div>차트 설정</div>
            <div>환자 접수 정보를 전송할 프로그램을 설정합니다.</div>
            <div>
                <button >드롭다운</button>
                {isOpen && (
                <ul className="dropdown-menu">
                    <li>Option 1</li>
                    <li>Option 2</li>
                    <li>Option 3</li>
        </ul>
      )}
            </div>
            <input type="checkbox"/>
            <span>환자조회</span>
        </div>



        

        <div className="optionBottom">
            <button className="optionBottom_btn1" type="submit">저장</button>
            <button className="optionBottom_btn2" type="button">취소</button>
        </div>
        </form>
        </>
    )
}