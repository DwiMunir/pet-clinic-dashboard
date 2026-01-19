import React, { forwardRef } from "react";

export interface MyCheckboxProps
  extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export const MyCheckbox = forwardRef<HTMLInputElement, MyCheckboxProps>(
  ({ label, error, className = "", ...props }, ref) => {
    return (
      <div className="flex items-start">
        <div className="flex items-center h-5">
          <input
            ref={ref}
            type="checkbox"
            className={`w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500 ${className}`}
            {...props}
          />
        </div>
        {label && (
          <div className="ml-3">
            <label className="text-sm text-gray-700">{label}</label>
            {error && <p className="text-sm text-red-600">{error}</p>}
          </div>
        )}
      </div>
    );
  }
);

MyCheckbox.displayName = "MyCheckbox";
