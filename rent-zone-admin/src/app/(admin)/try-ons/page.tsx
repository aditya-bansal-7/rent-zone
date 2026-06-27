"use client";

import { useState } from "react";
import { Wand2, Search, Trash2, Flag, Eye, AlertTriangle } from "lucide-react";
import { mockTryOns } from "@/lib/mock-data";
import { formatRelativeTime, getInitials, tryOnStatusColors, cn } from "@/lib/utils";
import type { TryOn } from "@/types";

const STATUS_TABS = [
  { value: "all", label: "All" },
  { value: "completed", label: "Completed" },
  { value: "pending", label: "Pending" },
  { value: "flagged", label: "Flagged" },
  { value: "failed", label: "Failed" },
] as const;

export default function TryOnsPage() {
  const [tryOns, setTryOns] = useState<TryOn[]>(mockTryOns);
  const [statusFilter, setStatusFilter] = useState<"all" | string>("all");
  const [search, setSearch] = useState("");

  const filtered = tryOns.filter((t) => {
    const q = search.toLowerCase();
    const matchSearch = t.user.name.toLowerCase().includes(q) || t.product.name.toLowerCase().includes(q);
    const matchStatus = statusFilter === "all" || t.status === statusFilter;
    return matchSearch && matchStatus;
  });

  const handleDelete = (id: string) => setTryOns((prev) => prev.filter((t) => t.id !== id));
  const handleFlag = (id: string) => setTryOns((prev) => prev.map((t) => t.id === id ? { ...t, status: "flagged" as const } : t));

  const counts: Record<string, number> = { all: tryOns.length };
  tryOns.forEach((t) => { counts[t.status] = (counts[t.status] ?? 0) + 1; });

  return (
    <div className="space-y-5 max-w-[1200px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Virtual Try-On Jobs</h2>
        <p className="text-sm text-gray-500">{tryOns.length} total jobs · {tryOns.filter((t) => t.status === "flagged").length} flagged</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-1">
        {STATUS_TABS.map((tab) => (
          <button key={tab.value} onClick={() => setStatusFilter(tab.value)}
            className={cn(
              "flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-sm font-medium transition-colors",
              statusFilter === tab.value ? "bg-purple-600 text-white" : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50"
            )}>
            {tab.label}
            {counts[tab.value] !== undefined && (
              <span className={cn("px-1.5 py-0.5 rounded-full text-xs font-bold", statusFilter === tab.value ? "bg-white/20 text-white" : "bg-gray-100 text-gray-500")}>
                {counts[tab.value]}
              </span>
            )}
          </button>
        ))}
      </div>

      {/* Search */}
      <div className="admin-card p-4">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
          <input type="text" placeholder="Search by user or product..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9" />
        </div>
      </div>

      {/* Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((tryOn) => (
          <div key={tryOn.id} className={cn("admin-card overflow-hidden hover:shadow-card-hover transition-shadow", tryOn.status === "flagged" && "border-red-200")}>
            {/* Result Preview */}
            <div className="h-40 bg-gradient-to-br from-purple-100 to-violet-100 flex items-center justify-center relative">
              {tryOn.status === "completed" ? (
                <div className="text-5xl">👗✨</div>
              ) : tryOn.status === "pending" ? (
                <div className="flex flex-col items-center gap-2">
                  <div className="w-8 h-8 border-2 border-purple-400 border-t-transparent rounded-full animate-spin" />
                  <p className="text-xs text-purple-500">Processing...</p>
                </div>
              ) : tryOn.status === "flagged" ? (
                <div className="flex flex-col items-center gap-2">
                  <AlertTriangle size={32} className="text-red-400" />
                  <p className="text-xs text-red-500">Flagged content</p>
                </div>
              ) : (
                <div className="flex flex-col items-center gap-2">
                  <Wand2 size={24} className="text-gray-300" />
                  <p className="text-xs text-gray-400">Failed to generate</p>
                </div>
              )}
              <div className="absolute top-2 right-2">
                <span className={`badge ${tryOnStatusColors[tryOn.status]}`}>{tryOn.status}</span>
              </div>
            </div>

            {/* Info */}
            <div className="p-4">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <div className="flex items-center gap-2">
                    <div className="w-6 h-6 rounded-full bg-purple-100 flex items-center justify-center text-purple-600 text-[10px] font-bold">
                      {getInitials(tryOn.user.name)}
                    </div>
                    <p className="text-sm font-medium text-gray-800">{tryOn.user.name}</p>
                  </div>
                  <p className="text-xs text-gray-500 mt-1 ml-8">{tryOn.product.name}</p>
                </div>
              </div>
              <div className="flex items-center justify-between mt-3">
                <div>
                  <p className="text-xs text-gray-400">Model: <span className="text-gray-600">{tryOn.modelUsed}</span></p>
                  <p className="text-xs text-gray-400">{formatRelativeTime(tryOn.createdAt)}</p>
                </div>
                <div className="flex items-center gap-1">
                  {tryOn.status !== "flagged" && (
                    <button onClick={() => handleFlag(tryOn.id)} className="p-1.5 rounded-lg hover:bg-amber-50 text-gray-400 hover:text-amber-500 transition-colors" title="Flag">
                      <Flag size={14} />
                    </button>
                  )}
                  <button onClick={() => handleDelete(tryOn.id)} className="p-1.5 rounded-lg hover:bg-red-50 text-gray-400 hover:text-red-500 transition-colors" title="Delete">
                    <Trash2 size={14} />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="admin-card empty-state py-16">
          <div className="empty-state-icon"><Wand2 size={24} /></div>
          <p className="text-sm font-medium text-gray-600">No try-on jobs found</p>
        </div>
      )}
    </div>
  );
}
