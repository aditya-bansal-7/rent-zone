"use client";

import { useState } from "react";
import { mockCategories } from "@/lib/mock-data";
import { Plus, Edit2, Trash2, GripVertical, Package } from "lucide-react";
import type { Category } from "@/types";
import { formatDate, cn } from "@/lib/utils";

export default function CategoriesPage() {
  const [categories, setCategories] = useState<Category[]>(mockCategories);
  const [typeFilter, setTypeFilter] = useState<"all" | "men" | "women">("all");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  const [newCat, setNewCat] = useState({ name: "", type: "women" as "men" | "women" });

  const filtered = typeFilter === "all" ? categories : categories.filter((c) => c.type === typeFilter);

  const handleAdd = () => {
    if (!newCat.name.trim()) return;
    const cat: Category = {
      id: `cat${Date.now()}`, name: newCat.name, type: newCat.type,
      order: categories.length + 1, createdAt: new Date().toISOString(), _count: { products: 0 }
    };
    setCategories((prev) => [...prev, cat]);
    setNewCat({ name: "", type: "women" });
    setShowAddForm(false);
  };

  const handleDelete = (id: string) => setCategories((prev) => prev.filter((c) => c.id !== id));

  return (
    <div className="space-y-5 max-w-[900px]">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-bold text-gray-900">Categories</h2>
          <p className="text-sm text-gray-500">{categories.length} categories · drag to reorder</p>
        </div>
        <button onClick={() => setShowAddForm(true)} className="btn-primary">
          <Plus size={15} /> Add Category
        </button>
      </div>

      {/* Add Form */}
      {showAddForm && (
        <div className="admin-card p-5 border-purple-100 bg-purple-50/40">
          <p className="font-semibold text-gray-800 mb-4">New Category</p>
          <div className="flex gap-3 items-end flex-wrap">
            <div className="flex-1 min-w-[180px]">
              <label className="block text-xs font-medium text-gray-600 mb-1">Name</label>
              <input type="text" value={newCat.name} onChange={(e) => setNewCat((p) => ({ ...p, name: e.target.value }))} className="form-input" placeholder="e.g. Bridal Wear" />
            </div>
            <div>
              <label className="block text-xs font-medium text-gray-600 mb-1">Type</label>
              <select value={newCat.type} onChange={(e) => setNewCat((p) => ({ ...p, type: e.target.value as "men" | "women" }))} className="form-select w-32">
                <option value="women">Women</option>
                <option value="men">Men</option>
              </select>
            </div>
            <div className="flex gap-2">
              <button onClick={handleAdd} className="btn-primary py-2">Add</button>
              <button onClick={() => setShowAddForm(false)} className="btn-secondary py-2">Cancel</button>
            </div>
          </div>
        </div>
      )}

      {/* Filter tabs */}
      <div className="flex gap-2">
        {(["all","women","men"] as const).map((t) => (
          <button key={t} onClick={() => setTypeFilter(t)}
            className={cn("px-4 py-1.5 rounded-lg text-sm font-medium transition-colors capitalize", typeFilter === t ? "bg-purple-600 text-white" : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50")}>
            {t === "all" ? "All" : t === "women" ? "👩 Women" : "👨 Men"}
          </button>
        ))}
      </div>

      {/* Category List */}
      <div className="space-y-2">
        {filtered.map((cat, idx) => (
          <div key={cat.id} className={cn("admin-card p-4 flex items-center gap-4 hover:shadow-card-hover transition-shadow", editingId === cat.id && "ring-2 ring-purple-300")}>
            <GripVertical size={18} className="text-gray-300 cursor-grab flex-shrink-0" />
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-purple-100 to-violet-100 flex items-center justify-center text-purple-600 font-bold text-sm flex-shrink-0">
              {idx + 1}
            </div>
            <div className="flex-1 min-w-0">
              {editingId === cat.id ? (
                <input
                  type="text"
                  defaultValue={cat.name}
                  className="form-input text-sm py-1.5 w-full max-w-xs"
                  onBlur={(e) => {
                    setCategories((prev) => prev.map((c) => c.id === cat.id ? { ...c, name: e.target.value } : c));
                    setEditingId(null);
                  }}
                  autoFocus
                />
              ) : (
                <p className="font-semibold text-gray-800">{cat.name}</p>
              )}
              <div className="flex items-center gap-2 mt-1">
                <span className={`badge ${cat.type === "women" ? "badge-purple" : "badge-blue"}`}>{cat.type}</span>
                <span className="text-xs text-gray-400 flex items-center gap-1">
                  <Package size={11} /> {cat._count.products} products
                </span>
                <span className="text-xs text-gray-400">Added {formatDate(cat.createdAt)}</span>
              </div>
            </div>
            <div className="flex items-center gap-1 flex-shrink-0">
              <button onClick={() => setEditingId(cat.id)} className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors">
                <Edit2 size={14} />
              </button>
              <button onClick={() => handleDelete(cat.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors">
                <Trash2 size={14} />
              </button>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="empty-state admin-card py-16">
          <div className="empty-state-icon"><Package size={24} /></div>
          <p className="text-sm font-medium text-gray-700">No categories</p>
          <p className="text-xs text-gray-400 mt-1">Add your first category</p>
        </div>
      )}
    </div>
  );
}
