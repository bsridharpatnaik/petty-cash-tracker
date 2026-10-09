import React from 'react'
import { ReactComponent as PlusIcon } from "../../assets/svgs/plus.svg";
import "./index.css"
const AddButton = ({onClick}) => {
  return (
    <div className="add-button">
    <button className="plus-icon" onClick={onClick} >
        <PlusIcon  />
    </button>
</div>

  )
}

export default AddButton
