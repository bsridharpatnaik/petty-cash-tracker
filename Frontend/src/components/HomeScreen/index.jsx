import React from 'react';

const HomeScreen = () => {
  return (
    <div style={{ width: '100%', height: '100vh', overflow: 'hidden', display: 'flex', flexDirection: 'column' }}>
      <div style={{ flex: 1, overflow: 'hidden' }}>
        <iframe 
          src="https://example.com/" 
          width="100%" 
          height="100%" 
          style={{ border: 'none' }}
          title="Expense Tracker"
        ></iframe>
      </div>
      {/* <div style={{ backgroundColor: '#232323', padding: '20px', textAlign: 'center', color: '#fff' }}>
        <p style={{ fontSize: '16px', margin: '0' }}>We hope to see you again soon. <a href='/login' style={{color:"#9A9A9A",textDecoration:"none"}}>Coming Soon</a> for more details.</p>
      </div> */}
    </div>
  );
}

export default HomeScreen;
