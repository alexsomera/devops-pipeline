import React, { useState } from "react";
import Button from "../Button/Button";
import Modal from "../Modal/Modal";
import * as bootstrap from "bootstrap";
import carsData from "../../carsData";
import FormItem from "../FormItem/FormItem";
import Anchor from "../Anchor/Anchor";

if (!localStorage.getItem("cars")) {
    localStorage.setItem("cars", JSON.stringify(carsData));
}


const carros = JSON.parse(localStorage.getItem("cars"));

const CarForm = () => {
    
    let [index, setIndex] = useState(6);
    
    if (!localStorage.getItem("index")) {
        localStorage.setItem("index", JSON.stringify(index));
    }

    index = JSON.parse(localStorage.getItem("index"));
    
    
    const [cars, setCars] = useState([...carros]);
    
    
    const [car, setCar] = useState(
        window.location.search ? cars.find((car) => car.id === parseInt(window.location.search.replace("?id=", ""))) : index
    );
    
    console.log(index);
    const setAlert = (message) => {
        const modal = new bootstrap.Modal(document.getElementById("modal"));
        document.querySelector(".modal-title").textContent = message;
        modal.show();
    }

    const handleChange = (e) => {
        setCar({
            ...car,
            [e.target.id]: e.target.value
        });
        document.getElementById(e.target.id).classList.remove("is-invalid");      
    }
 

    const handleSubmit = (e) => {
        e.preventDefault();


        let brand = document.getElementById("brand").value;
        let model = document.getElementById("model").value;
        let year = document.getElementById("year").value;
        let color = document.getElementById("color").value;
        let price = document.getElementById("price").value;
        
        if (!brand || !model || !year || !color || !price) {
            setAlert("Preencha todos os campos!");
            document.querySelectorAll("input").forEach((input) => {
                if (!input.value) {
                    input.classList.add("is-invalid");
                }
            });
            return;
        }
        
        if (year < 1900 || year > new Date().getFullYear()) {
            setAlert("Ano inválido!");
            document.getElementById("year").classList.add("is-invalid");
            return;
        }

        if (price < 0) {
            setAlert("Preço inválido!");
            document.getElementById("price").classList.add("is-invalid");
            return;
        }

        if (car.id) {
            const indice = cars.findIndex((cars) => cars.id === car.id);
            setCar({ ...car, id: indice });
            cars[indice] = car;
            setCars([...cars]);
            localStorage.setItem("cars", JSON.stringify(cars));

            
            setAlert("Carro editado com sucesso!");

            window.location.href = "/cars";
            
        } else {
            let id = index;
            setCar({ ...car, id });
            cars.push({ ...car, id });
            setCars([...cars]);
            localStorage.setItem("cars", JSON.stringify(cars));
            setIndex(index + 1);
            localStorage.setItem("index", JSON.stringify(index + 1));
            
            setAlert("Carro adicionado com sucesso!");
            
            window.location.href = "/cars";
        }

        e.target.reset();
    }

    return (
        <main className="container">
            <h1>Adicionar Carro</h1>
            <form  onSubmit={(e) => handleSubmit(e)}>

                <FormItem id="brand" label="Marca" type="text" value={car.brand} onChange={(e) => handleChange(e)} />
                <FormItem id="model" label="Modelo" type="text" value={car.model} onChange={(e) => handleChange(e)} />
                <FormItem id="year" label="Ano" type="number" value={car.year} onChange={(e) => handleChange(e)} />
                <FormItem id="color" label="Cor" type="text" value={car.color} onChange={(e) => handleChange(e)} />
                <FormItem id="price" label="Preço" type="number" value={car.price} onChange={(e) => handleChange(e)} />
                
                <Button type="submit" className="btn btn-warning">
                    {car.id ? "Salvar Alterações" : "Adicionar Carro"}
                </Button>
                <Anchor href="/cars" className="btn btn-default">
                    Cancelar
                </Anchor>

            </form>

            <Modal />

        </main>
    );
};

export default CarForm;