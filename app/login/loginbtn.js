'use client'

import React, { useState } from 'react';

export default function loginbtn() {
  const [buttonState, setButtonState] = useState('normal_new');

  const handleMouseEnter = () => {
    setButtonState('hover');
    console.log("마우스오버")
  };

  const handleMouseLeave = () => {
    setButtonState('normal_new');
    console.log("마우스리브")
  };

  const handleMouseDown = () => {
    setButtonState('down');
    console.log("마우스다운")
  };

  const handleMouseUp = () => {
    setButtonState('normal_new');
    console.log("마우스업")
  };

  return (
    // <div className="input-Loginbutton">
    //   <button type="submit" 
    //   onMouseEnter={handleMouseEnter} 
    //   onMouseLeave={handleMouseLeave} 
    //   onMouseDown={handleMouseDown}
    //   onMouseUp={handleMouseUp}>
    //   {buttonState === 'button1' && (
    //     <img src="/GDR/login_button_normal_new.png" alt="Button 1" />
    //   )}
    //   {buttonState === 'button2' && (
    //     <img src="/GDR/login_button_hover.png" alt="Button 2" />
    //   )}
    //   {buttonState === 'button3' && (
    //     <img src="/GDR/login_button_down.png" alt="Button 3" />
    //   )}
    //   </button>
      
    // </div>
    <div className="input-Loginbutton">
    <button 
      type="submit" 
      onMouseEnter={handleMouseEnter} 
      onMouseLeave={handleMouseLeave} 
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}
    >
     시작하기
    </button>

  </div>
  );
}