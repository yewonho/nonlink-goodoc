export default function DetailView(){
    return(
        <div className="detailView">
            <div>
                <span>상태</span>
                <span>접수 요청</span>
            </div>
            <div>
                <span>이름</span>
                <input type="text"/>
            </div>
            <div>
                <span>연락처</span>
                <input type="text"/>
            </div>
            <div>
                <span>주민번호</span>
                <input type="text"/>
            </div>
            <div>
                <span>내원목적</span>
                <input type="text"/>
            </div>
            <div>
                <span>내원경로</span>
                <input type="text"/>
            </div>
            <div>
                <span>주소</span>
                <textarea/>
            </div>
            <div>
                <span>진료실</span>
                <input type="text"/>
            </div>
            <div>
                <span>수단</span>
                <span>태블릿</span>
            </div>
            <div>
                <span>요청시각</span>
                <input type="text"/>
            </div>
            <div>
                <span>메모</span>
                <span>시간</span>
            </div>
            <div className="detailBottom">
                <img className="detailBottom1" src="/GDR/type_c_1_nor.png"/>
                <img className="detailBottom2" src="/GDR/reception_cancel_detail_normal.png"/>
            </div>
        </div>
    )
}