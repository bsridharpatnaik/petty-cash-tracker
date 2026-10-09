import * as React from "react";
const SvgThree = (props) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    width={21}
    height={21}
    fill="none"
    {...props}
  >
    <path
      stroke="#fff"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeMiterlimit={10}
      strokeWidth={1.5}
      d="M10.826 20.25a9.424 9.424 0 1 0 0-18.848 9.424 9.424 0 0 0 0 18.848"
    />
    <path
      stroke="#fff"
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeMiterlimit={10}
      strokeWidth={1.5}
      d="M10.826 11.754a3.32 3.32 0 1 0 0-6.64 3.32 3.32 0 0 0 0 6.64"
    />
    <mask id="three_svg__a" fill="#fff">
      <path d="M4.756 18.992a6.105 6.105 0 0 1 12.14 0" />
    </mask>
    <path
      fill="#fff"
      d="M6.247 19.15a1.5 1.5 0 1 1-2.983-.317zm12.14-.317a1.5 1.5 0 1 1-2.983.317zm-15.123 0a7.605 7.605 0 0 1 7.562-6.794v3a4.605 4.605 0 0 0-4.579 4.111zm7.562-6.794a7.605 7.605 0 0 1 7.561 6.794l-2.983.317a4.605 4.605 0 0 0-4.578-4.11z"
      mask="url(#three_svg__a)"
    />
  </svg>
);
export default SvgThree;
