"use client";

import Link from "next/link";
import { ShieldAlert, ArrowLeft } from "lucide-react";

export default function UnauthorizedPage() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-white to-violet-50 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white rounded-2xl shadow-modal border border-purple-100 p-8 text-center">
        <div className="w-20 h-20 bg-red-50 rounded-full flex items-center justify-center mx-auto mb-6">
          <ShieldAlert className="w-10 h-10 text-red-500" />
        </div>
        
        <h1 className="text-2xl font-bold text-gray-900 mb-2">Access Denied</h1>
        <p className="text-sm text-gray-500 mb-8">
          You do not have permission to access the admin dashboard. This area is restricted to authorized platform administrators only.
        </p>
        
        <Link 
          href="/login" 
          className="btn-primary w-full justify-center py-2.5"
        >
          <ArrowLeft size={16} className="mr-2" /> Return to Login
        </Link>
      </div>
    </div>
  );
}
