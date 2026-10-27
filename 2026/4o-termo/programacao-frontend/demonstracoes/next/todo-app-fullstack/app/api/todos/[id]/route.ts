import connectMongo from "@/lib/mongodb";
import Todo from "@/model/Todo";
import { NextRequest, NextResponse } from "next/server";

interface RouteContext {
  params: Promise<{ id: string }> | { id: string };
}

// Atualiza o status ou titulo de uma tarefa por ID
export async function PUT(req: NextRequest, context: RouteContext) {
  try {
    await connectMongo();
    const { id } = await context.params;
    const body = await req.json();

    const updated = await Todo.findByIdAndUpdate(id, body, {
      new: true,
      runValidators: true
    });

    if (!updated) {
      return NextResponse.json({ success: false, error: "Tarefa não encontrada." }, { status: 404 });
    }

    return NextResponse.json({ success: true, data: updated }, { status: 200 });
  } catch (error: any) {
    return NextResponse.json({ success: false, error: error.message || "ID inválido." }, { status: 400 });
  }
}

// Remove uma tarefa existente por ID
export async function DELETE(_req: NextRequest, context: RouteContext) {
  try {
    await connectMongo();
    const { id } = await context.params;

    const result = await Todo.findByIdAndDelete(id);
    if (!result) {
      return NextResponse.json({ success: false, error: "Tarefa não encontrada." }, { status: 404 });
    }

    return NextResponse.json({ success: true, message: "Tarefa excluída." }, { status: 200 });
  } catch (error) {
    return NextResponse.json({ success: false, error: "Falha ao excluir tarefa." }, { status: 400 });
  }
}