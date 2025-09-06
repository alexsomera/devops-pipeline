import React from "react";

const FormItem = ({ id, label, type, value, onChange }) => {
    return (
        <div className="mb-4">
            <label htmlFor={id} className="form-label">
                {label}
            </label>
            <input type={type} className="form-control" id={id} value={value} onChange={onChange} />
        </div>
    );
}

export default FormItem;