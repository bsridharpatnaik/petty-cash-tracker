import React from 'react';
import './index.css';

const Menu = ({ items,documentPage }) => {

  return (
    <div className={!documentPage ? "menu-container" : "menu-container-document"}>
      <ul className="menu-list">
        {items.map((item, index) => (
          <li key={index} className="menu-item" onClick={(e) => {
            e.stopPropagation(); 
            item.onClick();
          }}
          >
            {item.label}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default Menu;
