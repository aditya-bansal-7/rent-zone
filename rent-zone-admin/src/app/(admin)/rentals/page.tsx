"use client";

import { useState } from "react";
import { Search, Eye, CheckCircle, XCircle, RotateCcw, AlertTriangle } from "lucide-react";
import Link from "next/link";
import { mockRentals } from "@/lib/mock-data";
import { formatDate, formatCurrency, rentalStatusColors, cn } from "@/lib/utils";
import type { Rental, RentalStatus } from "@/types";

const STATUS_TABS: { value: RentalStatus | "all"; label: string }[] = [
  { value: "all",       label: "All" },
  { value: "requested", label: "Requested" },
  { value: "approved",  label: "Approved" },
  { value: "active",    label: "Active" },
  { value: "returned",  label: "Returned" },
  { value: "cancelled", label: "Cancelled" },
];

export default function RentalsPage() {
  const [search, setSearch] = useState("");
  const [statusTab, setStatusTab] = useState<RentalStatus | "all">("all");
  const [rentals, setRentals] = useState<Rental[]>(mockRentals);
  const [selectedRental, setSelectedRental] = useState<Rental | null>(null);

  const filtered = rentals.filter((r) => {
    const q = search.toLowerCase();
    const matchSearch = r.product.name.toLowerCase().includes(q) || r.rentedBy.name.toLowerCase().includes(q);
    const matchStatus = statusTab === "all" || r.status === statusTab;
    return matchSearch && matchStatus;
  });

  const counts: Record<string, number> = { all: rentals.length };
  rentals.forEach((r) => { counts[r.status] = (counts[r.status] ?? 0) + 1; });

  const handleAction = (rentalId: string, newStatus: RentalStatus) => {
    setRentals((prev) => prev.map((r) => r.id === rentalId ? { ...r, status: newStatus } : r));
    if (selectedRental?.id === rentalId) setSelectedRental((prev) => prev ? { ...prev, status: newStatus } : null);
  };

  return (
    <div className="space-y-5 max-w-[1400px]">
      <div>
        <h2 className="text-xl font-bold text-gray-900">Rental Management</h2>
        <p className="text-sm text-gray-500">{rentals.length} total rentals</p>
      </div>

      {/* Status tabs */}
      <div className="flex gap-1 overflow-x-auto pb-1">
        {STATUS_TABS.map((tab) => (
          <button key={tab.value} onClick={() => setStatusTab(tab.value)}
            className={cn(
              "flex items-center gap-1.5 px-3.5 py-2 rounded-lg text-sm font-medium transition-colors whitespace-nowrap",
              statusTab === tab.value ? "bg-purple-600 text-white" : "bg-white text-gray-600 border border-gray-200 hover:bg-gray-50"
            )}>
            {tab.label}
            {counts[tab.value] !== undefined && (
              <span className={cn("px-1.5 py-0.5 rounded-full text-xs font-bold", statusTab === tab.value ? "bg-white/20 text-white" : "bg-gray-100 text-gray-500")}>
                {counts[tab.value]}
              </span>
            )}
          </button>
        ))}
      </div>

      <div className="flex gap-4">
        {/* Table */}
        <div className={cn("admin-card overflow-hidden flex-1", selectedRental && "max-w-[65%]")}>
          <div className="p-4 border-b border-gray-50">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 w-4 h-4" />
              <input type="text" placeholder="Search by product or renter..." value={search} onChange={(e) => setSearch(e.target.value)} className="form-input pl-9" />
            </div>
          </div>
          <div className="overflow-x-auto">
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Renter</th>
                  <th>Owner</th>
                  <th>Dates</th>
                  <th>Total</th>
                  <th>Status</th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {filtered.map((rental) => (
                  <tr key={rental.id} className={cn(selectedRental?.id === rental.id && "bg-purple-50/50")}>
                    <td className="font-medium text-gray-800">{rental.product.name}</td>
                    <td className="text-gray-600">{rental.rentedBy.name}</td>
                    <td className="text-gray-600">{rental.rentedFrom.name}</td>
                    <td className="text-gray-500 text-xs">
                      {new Date(rental.startDate).toLocaleDateString("en-IN", { day:"numeric", month:"short" })} —{" "}
                      {new Date(rental.endDate).toLocaleDateString("en-IN", { day:"numeric", month:"short" })}
                    </td>
                    <td className="font-semibold text-gray-800">{formatCurrency(rental.totalPrice)}</td>
                    <td><span className={`badge ${rentalStatusColors[rental.status]}`}>{rental.status}</span></td>
                    <td>
                      <button onClick={() => setSelectedRental(selectedRental?.id === rental.id ? null : rental)}
                        className="p-1.5 rounded-lg hover:bg-purple-50 text-gray-400 hover:text-purple-600 transition-colors">
                        <Eye size={15} />
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {filtered.length === 0 && (
            <div className="empty-state py-12"><p className="text-sm text-gray-400">No rentals match your filters</p></div>
          )}
        </div>

        {/* Detail Drawer */}
        {selectedRental && (
          <div className="admin-card w-80 flex-shrink-0 overflow-y-auto max-h-[600px] animate-slide-in">
            <div className="px-5 py-4 border-b border-gray-50 flex items-center justify-between">
              <p className="font-semibold text-gray-800">Rental Detail</p>
              <button onClick={() => setSelectedRental(null)} className="text-gray-400 hover:text-gray-600 text-xl leading-none">×</button>
            </div>
            <div className="p-5 space-y-4">
              {/* Product */}
              <div className="p-3 bg-purple-50 rounded-xl">
                <p className="text-xs text-purple-500 font-medium mb-1">Product</p>
                <p className="font-semibold text-gray-800">{selectedRental.product.name}</p>
                <p className="text-sm text-gray-500">₹{selectedRental.product.rentPricePerDay}/day</p>
              </div>

              {/* Parties */}
              <div className="space-y-2">
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Renter</span>
                  <span className="font-medium text-gray-700">{selectedRental.rentedBy.name}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Owner</span>
                  <span className="font-medium text-gray-700">{selectedRental.rentedFrom.name}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Start</span>
                  <span className="font-medium text-gray-700">{formatDate(selectedRental.startDate)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">End</span>
                  <span className="font-medium text-gray-700">{formatDate(selectedRental.endDate)}</span>
                </div>
                <div className="flex justify-between text-sm border-t border-gray-100 pt-2">
                  <span className="text-gray-400">Total</span>
                  <span className="font-bold text-gray-900">{formatCurrency(selectedRental.totalPrice)}</span>
                </div>
                <div className="flex justify-between text-sm">
                  <span className="text-gray-400">Status</span>
                  <span className={`badge ${rentalStatusColors[selectedRental.status]}`}>{selectedRental.status}</span>
                </div>
              </div>

              {/* Actions */}
              <div className="space-y-2 pt-2 border-t border-gray-100">
                <p className="text-xs font-semibold text-gray-500 uppercase tracking-wide">Admin Actions</p>
                {selectedRental.status === "requested" && (
                  <button onClick={() => handleAction(selectedRental.id, "approved")} className="w-full btn-primary py-2 justify-center gap-1.5 text-xs">
                    <CheckCircle size={13} /> Approve Rental
                  </button>
                )}
                {selectedRental.status === "active" && (
                  <button onClick={() => handleAction(selectedRental.id, "returned")} className="w-full btn-primary py-2 justify-center gap-1.5 text-xs">
                    <RotateCcw size={13} /> Mark as Returned
                  </button>
                )}
                {(selectedRental.status === "requested" || selectedRental.status === "approved") && (
                  <button onClick={() => handleAction(selectedRental.id, "cancelled")} className="w-full btn-danger py-2 justify-center gap-1.5 text-xs">
                    <XCircle size={13} /> Cancel Rental
                  </button>
                )}
                <button className="w-full btn-secondary py-2 justify-center gap-1.5 text-xs text-amber-600 border-amber-200 hover:bg-amber-50">
                  <AlertTriangle size={13} /> Escalate Dispute
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
