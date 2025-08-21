import React from "react";
import NavBar from "../NavBar/NavBar";


const Header = (props) => {
    return (
        <header className={props.className}>
            <div className="container">
                <NavBar />
            </div>
        </header>
    )
}

export default Header