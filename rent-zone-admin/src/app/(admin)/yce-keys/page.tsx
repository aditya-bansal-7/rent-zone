"use client";

import { useEffect, useState } from "react";
import { Key, Plus, Trash2, Edit2, Check, X, Shield, Activity } from "lucide-react";
import { adminService } from "@/services/admin";

export default function YceKeysPage() {
  const [keys, setKeys] = useState<any[]>([]);
  const [stats, setStats] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [showAddModal, setShowAddModal] = useState(false);
  const [newKey, setNewKey] = useState({ name: "", key: "", credits: 540 });
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editCredits, setEditCredits] = useState<number>(0);

  const fetchKeys = async () => {
    try {
      setLoading(true);
      const res = await adminService.yceKeys.list({ limit: 100 });
      if (res) {
        setKeys(res.keys || []);
        setStats(res.stats || null);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchKeys();
  }, []);

  const handleAddKey = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await adminService.yceKeys.create(newKey);
      setShowAddModal(false);
      setNewKey({ name: "", key: "", credits: 540 });
      fetchKeys();
    } catch (err) {
      console.error(err);
      alert("Failed to add key. It might already exist.");
    }
  };

  const handleUpdateCredits = async (id: string) => {
    try {
      await adminService.yceKeys.update(id, { credits: editCredits });
      setEditingId(null);
      fetchKeys();
    } catch (err) {
      console.error(err);
      alert("Failed to update credits.");
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this API Key?")) return;
    try {
      await adminService.yceKeys.delete(id);
      fetchKeys();
    } catch (err) {
      console.error(err);
      alert("Failed to delete key.");
    }
  };

  const handleToggleStatus = async (id: string, currentStatus: boolean) => {
    try {
      await adminService.yceKeys.update(id, { isActive: !currentStatus });
      fetchKeys();
    } catch (err) {
      console.error(err);
    }
  };

  // Helper to mask key
  const maskKey = (key: string) => {
    if (!key || key.length < 10) return key;
    return `${key.substring(0, 6)}...${key.substring(key.length - 4)}`;
  };

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 flex items-center gap-2">
            <Key className="w-6 h-6 text-purple-600" />
            YCE API Keys Management
          </h1>
          <p className="text-gray-500 mt-1">Manage your Perfect Corp API keys and track credits.</p>
        </div>
        <button
          onClick={() => setShowAddModal(true)}
          className="bg-purple-600 text-white px-4 py-2 rounded-lg font-medium hover:bg-purple-700 flex items-center gap-2"
        >
          <Plus size={18} />
          Add API Key
        </button>
      </div>

      {stats && (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100 flex items-center gap-4">
            <div className="w-12 h-12 bg-purple-100 text-purple-600 rounded-full flex items-center justify-center">
              <Shield size={24} />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-500">Active Keys</p>
              <h3 className="text-2xl font-bold text-gray-900">{stats.activeKeys}</h3>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100 flex items-center gap-4">
            <div className="w-12 h-12 bg-green-100 text-green-600 rounded-full flex items-center justify-center">
              <Activity size={24} />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-500">Total Credits Left</p>
              <h3 className="text-2xl font-bold text-gray-900">{stats.totalCredits}</h3>
            </div>
          </div>
          <div className="bg-white rounded-xl shadow-sm p-6 border border-gray-100 flex items-center gap-4">
            <div className="w-12 h-12 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center">
              <Check size={24} />
            </div>
            <div>
              <p className="text-sm font-medium text-gray-500">Est. Try-Ons Left</p>
              <h3 className="text-2xl font-bold text-gray-900">{stats.estimatedTryOns}</h3>
            </div>
          </div>
        </div>
      )}

      <div className="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="bg-gray-50 border-b border-gray-100">
              <th className="p-4 font-semibold text-gray-600 text-sm">Name</th>
              <th className="p-4 font-semibold text-gray-600 text-sm">Key (Masked)</th>
              <th className="p-4 font-semibold text-gray-600 text-sm text-center">Credits</th>
              <th className="p-4 font-semibold text-gray-600 text-sm text-center">Status</th>
              <th className="p-4 font-semibold text-gray-600 text-sm text-center">Added On</th>
              <th className="p-4 font-semibold text-gray-600 text-sm text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="p-8 text-center text-gray-500">Loading...</td>
              </tr>
            ) : keys.length === 0 ? (
              <tr>
                <td colSpan={6} className="p-8 text-center text-gray-500">No API keys found.</td>
              </tr>
            ) : (
              keys.map((k) => (
                <tr key={k.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                  <td className="p-4 text-sm font-medium text-gray-900">{k.name || "Unnamed"}</td>
                  <td className="p-4 text-sm text-gray-500 font-mono">{maskKey(k.key)}</td>
                  <td className="p-4 text-center">
                    {editingId === k.id ? (
                      <div className="flex items-center justify-center gap-2">
                        <input
                          type="number"
                          value={editCredits}
                          onChange={(e) => setEditCredits(Number(e.target.value))}
                          className="w-20 border rounded px-2 py-1 text-sm"
                        />
                        <button onClick={() => handleUpdateCredits(k.id)} className="text-green-600 hover:text-green-700">
                          <Check size={16} />
                        </button>
                        <button onClick={() => setEditingId(null)} className="text-red-500 hover:text-red-600">
                          <X size={16} />
                        </button>
                      </div>
                    ) : (
                      <div className="flex items-center justify-center gap-2 group">
                        <span className={`font-semibold ${k.credits < 10 ? 'text-red-500' : 'text-gray-900'}`}>
                          {k.credits}
                        </span>
                        <button 
                          onClick={() => { setEditingId(k.id); setEditCredits(k.credits); }}
                          className="text-gray-400 hover:text-purple-600 opacity-0 group-hover:opacity-100 transition-opacity"
                        >
                          <Edit2 size={14} />
                        </button>
                      </div>
                    )}
                  </td>
                  <td className="p-4 text-center">
                    <button
                      onClick={() => handleToggleStatus(k.id, k.isActive)}
                      className={`px-3 py-1 rounded-full text-xs font-medium ${
                        k.isActive 
                          ? "bg-green-100 text-green-700" 
                          : "bg-red-100 text-red-700"
                      }`}
                    >
                      {k.isActive ? "Active" : "Inactive"}
                    </button>
                  </td>
                  <td className="p-4 text-center text-sm text-gray-500">
                    {new Date(k.createdAt).toLocaleDateString()}
                  </td>
                  <td className="p-4 text-right">
                    <button
                      onClick={() => handleDelete(k.id)}
                      className="text-gray-400 hover:text-red-600 p-2 rounded-lg hover:bg-red-50 transition-colors"
                      title="Delete Key"
                    >
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4 animate-fade-in">
          <div className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
              <h2 className="text-lg font-bold text-gray-900">Add New API Key</h2>
              <button onClick={() => setShowAddModal(false)} className="text-gray-400 hover:text-gray-600">
                <X size={20} />
              </button>
            </div>
            <form onSubmit={handleAddKey} className="p-6 space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Key Name / Identifier</label>
                <input
                  type="text"
                  required
                  value={newKey.name}
                  onChange={(e) => setNewKey({ ...newKey, name: e.target.value })}
                  placeholder="e.g. Account 1"
                  className="w-full border border-gray-200 rounded-lg px-4 py-2 focus:ring-2 focus:ring-purple-600/20 focus:border-purple-600 outline-none transition-all"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">API Key</label>
                <input
                  type="text"
                  required
                  value={newKey.key}
                  onChange={(e) => setNewKey({ ...newKey, key: e.target.value })}
                  placeholder="sk-..."
                  className="w-full border border-gray-200 rounded-lg px-4 py-2 focus:ring-2 focus:ring-purple-600/20 focus:border-purple-600 outline-none transition-all font-mono text-sm"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Starting Credits</label>
                <input
                  type="number"
                  required
                  value={newKey.credits}
                  onChange={(e) => setNewKey({ ...newKey, credits: Number(e.target.value) })}
                  className="w-full border border-gray-200 rounded-lg px-4 py-2 focus:ring-2 focus:ring-purple-600/20 focus:border-purple-600 outline-none transition-all"
                />
                <p className="text-xs text-gray-500 mt-1">Default is 540 credits per YCE account.</p>
              </div>
              <div className="pt-4 flex gap-3">
                <button
                  type="button"
                  onClick={() => setShowAddModal(false)}
                  className="flex-1 px-4 py-2 border border-gray-200 text-gray-700 rounded-lg font-medium hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="flex-1 px-4 py-2 bg-purple-600 text-white rounded-lg font-medium hover:bg-purple-700 transition-colors"
                >
                  Add Key
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
