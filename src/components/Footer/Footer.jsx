import React from "react";

const Footer = () => {
    return(
        <footer className="p-4 mt-auto">
            <div className="container text-center">
                CRUD Hot Wheels  - {new Date().getFullYear()} - Desenvolvido por Alex Fernando Somera
            </div>
        </footer>
    )
}

export default Footer