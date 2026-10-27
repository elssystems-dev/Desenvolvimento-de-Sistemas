// Interface base para conexão com o mongoDB

import mongoose, { Document, Model, Schema } from "mongoose";

export interface ITodoDocument extends Document {
    title: string;
    completed: boolean;
    createAt: Date;
}

const TodoSchema = new Schema<ITodoDocument>({
    title: {
        type: String,
        required: [true, "O título é obrigatório"],
        trim: true,
        minlength: [3, "O títlo deve ter pelo menos 3 caracteres"],
        maxLength: [100, "O título não pode exceder 100 caracteres"]
    },
    completed: {
        type: Boolean,
        default: false
    },
    createAt: {
        type: Date,
        default: Date.now
    }
});

// Método de criação do objeto a partir do modelo
const Todo: Model<ITodoDocument> = mongoose.models.Todo || mongoose.model<ITodoDocument>("Todo", TodoSchema);

export default Todo;