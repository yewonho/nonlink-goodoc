'use client'

import React, { useState } from 'react';

export default function loginbtn() {
  const [buttonState, setButtonState] = useState('normal');
  

  const handleMouseEnter = () => {
    setButtonState('hover');
    console.log("마우스오버")
    const button = document.querySelector('.input-Loginbutton');
    if (button) {
      button.style.backgroundColor = 'rgb(80, 185, 249)';
    }
  };

  const handleMouseLeave = () => {
    setButtonState('normal');
    console.log("마우스리브")
    const button = document.querySelector('.input-Loginbutton');
    if (button) {
      button.style.backgroundColor = 'rgb(0, 115, 250)';
    }
  };

  const handleMouseDown = () => {
    setButtonState('down');
    console.log("마우스다운")
    const button = document.querySelector('.input-Loginbutton');
    if (button) {
      button.style.backgroundColor = 'rgb(0, 116, 187)';
    }
  };

  const handleMouseUp = () => {
    setButtonState('normal');
    console.log("마우스업")
    const button = document.querySelector('.input-Loginbutton');
    if (button) {
      button.style.backgroundColor = 'rgb(0, 115, 250)';
    }
  };

  return (
    <div className="input-Loginbuttoncon">
    <button className='input-Loginbutton'
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