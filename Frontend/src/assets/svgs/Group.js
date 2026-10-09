import * as React from "react";
const SvgGroup = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={22}
    height={16}
    fill="none"
    {...props}
  >
    <circle cx={11} cy={8} r={2.75} stroke="#489C2C" strokeWidth={1.5} />
    <path
      stroke="#489C2C"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={1.5}
      d="M16.357 13.349Q13.912 14.999 11 15 5 15 1 8q2.053-3.592 4.632-5.341"
    />
  </svg>
);
export default SvgGroup;
