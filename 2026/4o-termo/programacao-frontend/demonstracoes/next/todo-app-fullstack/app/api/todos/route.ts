// rotas GET e POST 

import connectMongo from "@/lib/mongodb";
import Todo from "@/model/Todo";
import { NextRequest, NextResponse } from "next/server";

// método apra retornar a lista de tarefas
export async function GET(){
    try {
        await connectMongo();
        const todos = await Todo.find({}).sort({createAt: -1});
        return NextResponse.json({success: true, data: todos}, {status: 200});
    } catch (error) {
        return NextResponse.json(
            {success: false, error: "Falha ao consultar tarefa no banco"},
            {status: 500}
        );
    }
}

//método para adicionar uma tarefa no banco
export async function POST(req: NextRequest) {
    try {
        await connectMongo();
        const body = await req.json();

        if(!body.title || typeof body.title !== "string" || body.title.trim().length < 3){
            return NextResponse.json(
                {success:false, error: "Titulo inválido (mínimo de 3 Caracteres)"},
                {status: 400}
            );
        }

        const newTodo = await Todo.create({title: body.title.trim()});
        return NextResponse.json({success: true, data: newTodo},{status: 201});
    } catch (error) {
        return NextResponse.json(
            {success: false, error: "Erro ao criar tarefa"},
            {status: 500}
        );
    }
}