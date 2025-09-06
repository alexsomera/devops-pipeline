import React from "react";

const Anchor = (props) => {
    return(
        <a className={props.className} href={props.href}>
            {props.children}
        </a>
    );
}

export default Anchor