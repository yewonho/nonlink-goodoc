"use client"

export default function Navlayout(){

    const mauseOver = (event) => {
        const id = event.target.id;
        console.log(id);

        switch (id){
            case 'env' : 
                document.getElementById(id).src = "/GDR/env_over.png";
                break;
            
            case 'min' : 
                document.getElementById(id).src = "/GDR/min_over.png";
                break;

            case 'max' : 
                document.getElementById(id).src = "/GDR/max_over.png";
                break;

            case 'exit' : 
                document.getElementById(id).src = "/GDR/close_over.png";
                break;
        default:
            break;
        }
    }

    const mauseDown = (event) => {
        const id = event.target.id;
        console.log(id);

        switch (id){
            case 'env' : 
                document.getElementById(id).src = "/GDR/env_down.png";
                break;
            
            case 'min' : 
                document.getElementById(id).src = "/GDR/min_down.png";
                break;

            case 'max' : 
                document.getElementById(id).src = "/GDR/max_down.png";
                break;

            case 'exit' : 
                document.getElementById(id).src = "/GDR/close_down.png";
                break;
        default:
            break;
        }
    }

    const mauseLeave = (event) => {
        const id = event.target.id;
        console.log(id);

        switch (id){
            case 'env' : 
                document.getElementById(id).src = "/GDR/env_normal.png";
                break;
            
            case 'min' : 
                document.getElementById(id).src = "/GDR/min_normal.png";
                break;

            case 'max' : 
                document.getElementById(id).src = "/GDR/max_normal.png";
                break;

            case 'exit' : 
                document.getElementById(id).src = "/GDR/close_normal.png";
                break;
        default:
            break;
        }
    }

    const mauseUp = (event) => {
        const id = event.target.id;
        console.log(id);

        switch (id){
            case 'env' : 
                document.getElementById(id).src = "/GDR/env_normal.png";
                break;
            
            case 'min' : 
                document.getElementById(id).src = "/GDR/min_normal.png";
                break;

            case 'max' : 
                document.getElementById(id).src = "/GDR/max_normal.png";
                break;

            case 'exit' : 
                document.getElementById(id).src = "/GDR/close_normal.png";
                break;
        default:
            break;
        }
    }

    return(
        <nav className="navlayout">
        <img className="layoutIco" src="/GDR/GDReceptionReservation_Icon2.ico" alt="head Icon"/>
        <span>굿닥 병원 서비스</span>
        <il>
          <img src="/GDR/env_normal.png" alt="env Icon" id="env" 
          onMouseEnter={mauseOver} onMouseLeave={mauseLeave} onMouseDown={mauseDown} onMouseUp={mauseUp}/>
          
          <img src="/GDR/min_normal.png" alt="min Icon" id="min" 
          onMouseEnter={mauseOver} onMouseLeave={mauseLeave} onMouseDown={mauseDown} onMouseUp={mauseUp}/>
          
          <img src="/GDR/max_normal.png" alt="max Icon" id="max" 
          onMouseEnter={mauseOver} onMouseLeave={mauseLeave} onMouseDown={mauseDown} onMouseUp={mauseUp}/>
          
          <img src="/GDR/close_normal.png" alt="exit Icon" id="exit" 
          onMouseEnter={mauseOver} onMouseLeave={mauseLeave} onMouseDown={mauseDown} onMouseUp={mauseUp}/>
        </il>
      </nav>
    );
} 