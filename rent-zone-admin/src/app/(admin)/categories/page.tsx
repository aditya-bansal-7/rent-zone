"use client";

import { useState, useEffect } from "react";
import { Plus, Edit2, Trash2, FolderTree } from "lucide-react";
import { adminService } from "@/services/admin";

export default function CategoriesPage() {
  const [categories, setCategories] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState<any>(null);
  const [formData, setFormData] = useState({ name: "", type: "women", image: "", isDeleted: false });
  const [imageFile, setImageFile] = useState<File | null>(null);

  const fetchCategories = async () => {
    setLoading(true);
    try {
      const res = await adminService.categories.list();
      setCategories(res);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      const data = new FormData();
      data.append('name', formData.name);
      data.append('type', formData.type);
      if (editingCategory) {
        data.append('isDeleted', String(formData.isDeleted));
      }
      if (imageFile) {
        data.append('image', imageFile);
      } else if (!imageFile && formData.image && !editingCategory) {
        data.append('image', formData.image);
      }
      
      if (editingCategory) {
        await adminService.categories.update(editingCategory.id, data);
      } else {
        await adminService.categories.create(data);
      }
      setIsModalOpen(false);
      fetchCategories();
    } catch (err) {
      console.error(err);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this category?")) return;
    try {
      await adminService.categories.delete(id);
      fetchCategories();
    } catch (err) {
      console.error(err);
    }
  };

  const openModal = (category: any = null) => {
    setImageFile(null);
    if (category) {
      setEditingCategory(category);
      setFormData({ name: category.name, type: category.type, image: category.image, isDeleted: category.isDeleted || false });
    } else {
      setEditingCategory(null);
      setFormData({ name: "", type: "women", image: "", isDeleted: false });
    }
    setIsModalOpen(true);
  };

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Categories</h2>
          <p className="text-sm text-gray-500 mt-1">Manage product categories and types.</p>
        </div>
        <button onClick={() => openModal()} className="btn-primary">
          <Plus size={16} /> Add Category
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {loading ? (
          <div className="col-span-full flex justify-center py-10">
            <div className="w-8 h-8 border-4 border-purple-500 border-t-transparent rounded-full animate-spin"></div>
          </div>
        ) : categories.length === 0 ? (
          <div className="col-span-full admin-card py-20 text-center">
            <div className="w-12 h-12 rounded-full bg-gray-50 flex items-center justify-center mx-auto mb-3">
              <FolderTree className="text-gray-400" />
            </div>
            <p className="text-gray-500">No categories found</p>
          </div>
        ) : (
          categories.map((cat) => (
            <div key={cat.id} className="admin-card p-5 group flex flex-col">
              <div className="flex items-start justify-between mb-4">
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 rounded-xl bg-purple-50 flex items-center justify-center text-2xl shadow-sm overflow-hidden">
                    {cat.image?.startsWith('http') ? <img src={cat.image} alt={cat.name} className="w-full h-full object-cover" /> : cat.image}
                  </div>
                  <div>
                    <h3 className="font-semibold text-gray-900">{cat.name}</h3>
                    <div className="flex gap-2 mt-1">
                      <span className="badge badge-indigo capitalize">{cat.type}</span>
                      {cat.isDeleted && <span className="badge badge-red">Deleted</span>}
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                  <button onClick={() => openModal(cat)} className="p-1.5 text-gray-400 hover:text-blue-600 hover:bg-blue-50 rounded-lg">
                    <Edit2 size={15} />
                  </button>
                  <button onClick={() => handleDelete(cat.id)} className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-lg">
                    <Trash2 size={15} />
                  </button>
                </div>
              </div>
              <div className="mt-auto pt-4 border-t border-gray-50">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-gray-500">Products in category</span>
                  <span className="font-semibold text-gray-900">{cat._count?.products || 0}</span>
                </div>
              </div>
            </div>
          ))
        )}
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 bg-black/40 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-white rounded-2xl w-full max-w-md shadow-modal animate-slide-in">
            <div className="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
              <h3 className="font-bold text-gray-900">{editingCategory ? "Edit Category" : "Add Category"}</h3>
              <button onClick={() => setIsModalOpen(false)} className="text-gray-400 hover:text-gray-600">✕</button>
            </div>
            <form onSubmit={handleSubmit} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                <input required type="text" className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/30" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Type</label>
                <select className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/30" value={formData.type} onChange={e => setFormData({ ...formData, type: e.target.value })}>
                  <option value="women">Women</option>
                  <option value="men">Men</option>
                </select>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Image (Upload file or leave blank to keep current)</label>
                <input type="file" accept="image/*" className="w-full px-3 py-2 border border-gray-200 rounded-lg focus:ring-2 focus:ring-purple-500/30" onChange={e => setImageFile(e.target.files?.[0] || null)} />
                {editingCategory && formData.image && !imageFile && (
                  <div className="mt-2 flex items-center gap-2 text-sm text-gray-500">
                    <span>Current:</span>
                    {formData.image.startsWith('http') ? <img src={formData.image} alt="current" className="w-8 h-8 rounded object-cover" /> : <span>{formData.image}</span>}
                  </div>
                )}
              </div>
              {editingCategory && (
                <div className="flex items-center gap-2">
                  <input type="checkbox" id="isDeleted" checked={formData.isDeleted} onChange={e => setFormData({ ...formData, isDeleted: e.target.checked })} className="w-4 h-4 text-purple-600 rounded focus:ring-purple-500" />
                  <label htmlFor="isDeleted" className="text-sm font-medium text-gray-700">Mark as Deleted</label>
                </div>
              )}
              <div className="pt-4 flex justify-end gap-3">
                <button type="button" onClick={() => setIsModalOpen(false)} className="btn-secondary">Cancel</button>
                <button type="submit" className="btn-primary">{editingCategory ? "Update" : "Create"}</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
