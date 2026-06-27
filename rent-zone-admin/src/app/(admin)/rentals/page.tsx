"use client";

import { useState, useEffect } from "react";
import { Search, Filter, Eye } from "lucide-react";
import { adminService } from "@/services/admin";
import { formatCurrency, formatDate, rentalStatusColors } from "@/lib/utils";
import Link from "next/link";

export default function RentalsPage() {
  const [rentals, setRentals] = useState<any[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [status, setStatus] = useState("all");

  const fetchRentals = async () => {
    setLoading(true);
    try {
      const res = await adminService.rentals.list({ page, limit: 10, status: status !== "all" ? status : undefined });
      setRentals(res.rentals);
      setTotal(res.total);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchRentals();
  }, [page, status]);

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-900">Rentals</h2>
          <p className="text-sm text-gray-500 mt-1">Monitor all rental transactions and statuses.</p>
        </div>
      </div>

      <div className="admin-card p-4">
        <div className="flex flex-col sm:flex-row justify-between gap-4 mb-4">
          <div className="flex items-center gap-3 ml-auto">
            <select
              className="text-sm bg-gray-50 border border-gray-200 rounded-lg px-3 py-2 focus:outline-none focus:ring-2 focus:ring-purple-500/30"
              value={status}
              onChange={(e) => { setStatus(e.target.value); setPage(1); }}
            >
              <option value="all">All Statuses</option>
              <option value="requested">Requested</option>
              <option value="approved">Approved</option>
              <option value="active">Active</option>
              <option value="returned">Returned</option>
              <option value="cancelled">Cancelled</option>
            </select>
            <button className="btn-secondary whitespace-nowrap">
              <Filter size={16} /> Filters
            </button>
          </div>
        </div>

        <div className="overflow-x-auto">
          {loading ? (
             <div className="flex justify-center py-10"><div className="w-6 h-6 border-2 border-purple-500 border-t-transparent rounded-full animate-spin"></div></div>
          ) : (
            <table className="data-table">
              <thead>
                <tr>
                  <th>Product</th>
                  <th>Renter</th>
                  <th>Owner</th>
                  <th>Dates</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th className="text-right">Actions</th>
                </tr>
              </thead>
              <tbody>
                {rentals.map((rental) => (
                  <tr key={rental.id}>
                    <td>
                      <div className="flex items-center gap-3">
                        <img 
                          src={rental.product.imageURLs?.[0] || 'https://via.placeholder.com/40'} 
                          alt="" 
                          className="w-10 h-10 rounded-lg object-cover bg-gray-100"
                        />
                        <span className="font-medium text-gray-900">{rental.product.name}</span>
                      </div>
                    </td>
                    <td className="text-gray-700">{rental.rentedBy.name}</td>
                    <td className="text-gray-700">{rental.rentedFrom.name}</td>
                    <td className="text-gray-500 text-sm">
                      {formatDate(rental.startDate)} - {formatDate(rental.endDate)}
                    </td>
                    <td className="font-semibold text-gray-800">{formatCurrency(rental.totalPrice)}</td>
                    <td>
                      <span className={`badge ${rentalStatusColors[rental.status] || 'badge-gray'}`}>
                        {rental.status}
                      </span>
                    </td>
                    <td className="text-right">
                      <Link href={`/rentals/${rental.id}`} className="inline-flex p-1.5 text-gray-400 hover:text-purple-600 hover:bg-purple-50 rounded-lg transition-colors">
                        <Eye size={18} />
                      </Link>
                    </td>
                  </tr>
                ))}
                {rentals.length === 0 && (
                  <tr><td colSpan={7} className="text-center py-10 text-gray-500">No rentals found.</td></tr>
                )}
              </tbody>
            </table>
          )}
        </div>
        
        {!loading && total > 0 && (
          <div className="flex justify-between items-center mt-4 text-sm text-gray-500 px-2">
            <span>Showing {(page - 1) * 10 + 1} to {Math.min(page * 10, total)} of {total} rentals</span>
            <div className="flex gap-2">
              <button disabled={page === 1} onClick={() => setPage(p => p - 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Prev</button>
              <button disabled={page * 10 >= total} onClick={() => setPage(p => p + 1)} className="px-3 py-1 border rounded disabled:opacity-50 hover:bg-gray-50">Next</button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
