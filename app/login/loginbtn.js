'use client'

import React, { useState } from 'react';

export default function loginbtn() {
  const [buttonState, setButtonState] = useState('button1');

  const handleMouseEnter = () => {
    setButtonState('button2');
    console.log("마우스오버")
  };

  const handleMouseLeave = () => {
    setButtonState('button1');
    console.log("마우스리브")
  };

  const handleMouseDown = () => {
    setButtonState('button3');
    console.log("마우스다운")
  };

  const handleMouseUp = () => {
    setButtonState('button1');
    console.log("마우스업")
  };

  return (
    <div className="input-Loginbutton">
      <button type="submit" 
      onMouseEnter={handleMouseEnter} 
      onMouseLeave={handleMouseLeave} 
      onMouseDown={handleMouseDown}
      onMouseUp={handleMouseUp}>
      {buttonState === 'button1' && (
        <img src="/GDR/login_button_normal_new.png" alt="Button 1" />
      )}
      {buttonState === 'button2' && (
        <img src="/GDR/login_button_hover.png" alt="Button 2" />
      )}
      {buttonState === 'button3' && (
        <img src="/GDR/login_button_down.png" alt="Button 3" />
      )}
      </button>
      
    </div>
  );
}